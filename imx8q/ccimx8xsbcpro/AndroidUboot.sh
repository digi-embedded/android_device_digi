#!/bin/bash

# hardcode this one again in this shell script
CONFIG_REPO_PATH=device/nxp
DIGI_FIRMWARE_PATH=vendor/digi/firmware

# import other paths in the file "common/imx_path/ImxPathConfig.mk" of this
# repository

while read -r line
do
	if [ "$(echo ${line} | grep "=")" != "" ]; then
		env_arg=`echo ${line} | cut -d "=" -f1`
		env_arg=${env_arg%:}
		env_arg=`eval echo ${env_arg}`

		env_arg_value=`echo ${line} | cut -d "=" -f2`
		env_arg_value=`eval echo ${env_arg_value}`

		eval ${env_arg}=${env_arg_value}
	fi
done < ${CONFIG_REPO_PATH}/common/imx_path/ImxPathConfig.mk

if [ "${AARCH64_GCC_CROSS_COMPILE}" != "" ]; then
	ATF_CROSS_COMPILE=`eval echo ${AARCH64_GCC_CROSS_COMPILE}`
else
	echo ERROR: \*\*\* env AARCH64_GCC_CROSS_COMPILE is not set
	exit 1
fi

build_pre_image()
{
	echo "android build without building M4 image"
}

build_trustfence_tools_zip() {
	echo "== Building Trustfence tools ZIP"
	TF_TOOLS_DIR="trustfence-tools-${1}"
	UBOOT_SCRIPTS_DIR="$(realpath vendor/digi/uboot-imx/scripts)"
	TF_KEY_SCRIPTS_DIR="$(realpath device/digi/common/trustfence)"
	CSF_TEMPLATES="encrypt_ahab_uboot sign_ahab_uboot"

	(
		cd "${UBOOT_COLLECTION}" || { echo "[ERROR] cd \"${UBOOT_COLLECTION}\""; return; }
		mkdir -p "${TF_TOOLS_DIR}"/bin "${TF_TOOLS_DIR}"/csf_templates
		mv mkimage*.log "${TF_TOOLS_DIR}"

		install -m 0755 "${UBOOT_SCRIPTS_DIR}"/sign_spl_ahab.sh "${TF_TOOLS_DIR}"/trustfence-sign-uboot.sh
		install -m 0755 "${TF_KEY_SCRIPTS_DIR}"/keys/ahab_pki_tree.sh "${TF_TOOLS_DIR}"/bin/trustfence-gen-pki.sh
		install -m 0755 "${TF_KEY_SCRIPTS_DIR}"/ca/openssl.cnf "${TF_TOOLS_DIR}"/bin/openssl.cnf
		install -m 0755 "${TF_KEY_SCRIPTS_DIR}"/ca/v3_ca.cnf "${TF_TOOLS_DIR}"/bin/v3_ca.cnf
		install -m 0755 "${TF_KEY_SCRIPTS_DIR}"/ca/v3_usr.cnf "${TF_TOOLS_DIR}"/bin/v3_usr.cnf
		for f in ${CSF_TEMPLATES}; do
			cp --remove-destination "${UBOOT_SCRIPTS_DIR}"/csf_templates/"${f}" "${TF_TOOLS_DIR}"/csf_templates
		done
		zip -qXr "${TF_TOOLS_DIR}".zip "${TF_TOOLS_DIR}"
		rm -rf "${TF_TOOLS_DIR}"
	)
}

build_imx_uboot()
{
	echo "== Building i.MX U-Boot"
	UBOOT_PLATFORM="${2}"
	SCFW_PLATFORM="$(echo "${UBOOT_PLATFORM}" | cut -d'-' -f1)"
	MKIMAGE_PLATFORM="iMX8QX"
	ATF_PLATFORM="imx8qx"
	REV="B0"
	if [ "$(echo "${UBOOT_PLATFORM}" | cut -d'-' -f2)" = "C0" ]; then
		REV="C0"
	fi

	make -C "${IMX_PATH}"/arm-trusted-firmware/ PLAT=${ATF_PLATFORM} clean
	if [ "$(echo "${UBOOT_PLATFORM}" | cut -d '-' -f3)" = "trusty" ]; then
		cp --remove-destination "${DIGI_FIRMWARE_PATH}"/uboot-firmware/imx8q/tee-"${SCFW_PLATFORM}".bin "${IMX_MKIMAGE_PATH}"/imx-mkimage/${MKIMAGE_PLATFORM}/tee.bin
		make -C "${IMX_PATH}"/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=${ATF_PLATFORM} bl31 SPD=trusty -B 1>/dev/null || exit 1
	else
		rm -f "${IMX_MKIMAGE_PATH}"/imx-mkimage/${MKIMAGE_PLATFORM}/tee.bin
		make -C "${IMX_PATH}"/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=${ATF_PLATFORM} bl31 -B 1>/dev/null || exit 1
	fi
	cp --remove-destination "${IMX_PATH}"/arm-trusted-firmware/build/${ATF_PLATFORM}/release/bl31.bin "${IMX_MKIMAGE_PATH}"/imx-mkimage/${MKIMAGE_PLATFORM}/bl31.bin
	cp --remove-destination "${FSL_PROPRIETARY_PATH}"/imx-seco/firmware/seco/mx8qx*ahab-container.img "${IMX_MKIMAGE_PATH}"/imx-mkimage/$MKIMAGE_PLATFORM/
	cp --remove-destination "${DIGI_FIRMWARE_PATH}"/uboot-firmware/imx8q/"${SCFW_PLATFORM}"_scfw-tcm.bin "${IMX_MKIMAGE_PATH}"/imx-mkimage/${MKIMAGE_PLATFORM}/scfw_tcm.bin
	cp --remove-destination "${UBOOT_OUT}"/u-boot."${1}" "${IMX_MKIMAGE_PATH}"/imx-mkimage/${MKIMAGE_PLATFORM}/u-boot.bin
	cp --remove-destination "${UBOOT_OUT}"/spl/u-boot-spl.bin "${IMX_MKIMAGE_PATH}"/imx-mkimage/${MKIMAGE_PLATFORM}/u-boot-spl.bin
	cp --remove-destination "${UBOOT_OUT}"/tools/mkimage  "${IMX_MKIMAGE_PATH}"/imx-mkimage/${MKIMAGE_PLATFORM}/mkimage_uboot
	make -C "${IMX_MKIMAGE_PATH}"/imx-mkimage/ clean
	pwd_backup=${PWD}
	PWD=${PWD}/"${IMX_MKIMAGE_PATH}"/imx-mkimage/
	make --no-print-directory -C "${IMX_MKIMAGE_PATH}"/imx-mkimage/ SOC=${MKIMAGE_PLATFORM} REV=${REV} flash_spl 2>&1 | tee "${UBOOT_COLLECTION}"/mkimage.log || exit 1
	PWD=${pwd_backup}
	cp --remove-destination "${IMX_MKIMAGE_PATH}"/imx-mkimage/${MKIMAGE_PLATFORM}/flash.bin "${UBOOT_COLLECTION}"/u-boot-"${UBOOT_PLATFORM}".imx
	build_trustfence_tools_zip "${UBOOT_PLATFORM}"
}
