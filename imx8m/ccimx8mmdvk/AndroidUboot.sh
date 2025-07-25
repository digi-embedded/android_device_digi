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
	:
}

build_trustfence_tools_zip() {
	echo "== Building Trustfence tools ZIP"
	TF_TOOLS_DIR="trustfence-tools-${1}"
	UBOOT_SCRIPTS_DIR="$(realpath vendor/digi/uboot-imx/scripts)"
	TF_KEY_SCRIPTS_DIR="$(realpath device/digi/common/trustfence)"
	CSF_TEMPLATES="encrypt_sign_uboot_fit encrypt_sign_uboot_spl encrypt_uboot_fit encrypt_uboot_spl sign_uboot_fit sign_uboot_spl"

	(
		cd "${UBOOT_COLLECTION}" || { echo "[ERROR] cd \"${UBOOT_COLLECTION}\""; return; }
		mkdir -p "${TF_TOOLS_DIR}"/bin "${TF_TOOLS_DIR}"/csf_templates
		mv mkimage*.log "${TF_TOOLS_DIR}"
		install -m 0755 "${UBOOT_SCRIPTS_DIR}"/sign_spl_fit.sh "${TF_TOOLS_DIR}"/trustfence-sign-uboot.sh
		install -m 0755 "${TF_KEY_SCRIPTS_DIR}"/keys/hab4_pki_tree.sh "${TF_TOOLS_DIR}"/bin/trustfence-gen-pki.sh
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
	echo Building i.MX U-Boot with firmware
	UBOOT_PLATFORM="${2}"
	UBOOT_DTB="ccimx8mm-dvk.dtb"
	MKIMAGE_PLATFORM="iMX8MM"
	TEE_LOAD_ADDR="0x7e000000"
	ATF_PLATFORM="imx8mm"
	cp --remove-destination "${UBOOT_OUT}"/u-boot-nodtb.bin "${IMX_MKIMAGE_PATH}"/imx-mkimage/iMX8M/.
	cp --remove-destination "${UBOOT_OUT}"/spl/u-boot-spl.bin  "${IMX_MKIMAGE_PATH}"/imx-mkimage/iMX8M/.
	cp --remove-destination "${UBOOT_OUT}"/tools/mkimage  "${IMX_MKIMAGE_PATH}"/imx-mkimage/iMX8M/mkimage_uboot
	cp --remove-destination "${UBOOT_OUT}"/arch/arm/dts/${UBOOT_DTB} "${IMX_MKIMAGE_PATH}"/imx-mkimage/iMX8M/.
	cp --remove-destination "${FSL_PROPRIETARY_PATH}"/linux-firmware-imx/firmware/ddr/synopsys/lpddr4_pmu_train* "${IMX_MKIMAGE_PATH}"/imx-mkimage/iMX8M/.

	make -C "${IMX_PATH}"/arm-trusted-firmware/ PLAT=${ATF_PLATFORM} realclean
	if [ "$(echo "${UBOOT_PLATFORM}" | cut -d '-' -f2)" = "trusty" ]; then
		cp --remove-destination "${DIGI_FIRMWARE_PATH}"/uboot-firmware/imx8m/tee-ccimx8mm.bin "${IMX_MKIMAGE_PATH}"/imx-mkimage/iMX8M/tee.bin
		make -C "${IMX_PATH}"/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=${ATF_PLATFORM} bl31 -B SPD=trusty IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
	else
		rm -f "${IMX_MKIMAGE_PATH}"/imx-mkimage/${MKIMAGE_PLATFORM}/tee.bin
		make -C "${IMX_PATH}"/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=${ATF_PLATFORM} bl31 -B IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
	fi
	cp --remove-destination "${IMX_PATH}"/arm-trusted-firmware/build/${ATF_PLATFORM}/release/bl31.bin "${IMX_MKIMAGE_PATH}"/imx-mkimage/iMX8M/bl31.bin

	make -C "${IMX_MKIMAGE_PATH}"/imx-mkimage/ clean
	make --no-print-directory -C "${IMX_MKIMAGE_PATH}"/imx-mkimage/ SOC=${MKIMAGE_PLATFORM} TEE_LOAD_ADDR=${TEE_LOAD_ADDR} dtbs=${UBOOT_DTB} flash_spl_uboot 2>&1 | tee "${UBOOT_COLLECTION}"/mkimage.log || exit 1
	cp --remove-destination "${UBOOT_OUT}"/arch/arm/dts/${UBOOT_DTB} "${IMX_MKIMAGE_PATH}"/imx-mkimage/iMX8M/.
	make --no-print-directory -C "${IMX_MKIMAGE_PATH}"/imx-mkimage/ SOC=${MKIMAGE_PLATFORM} TEE_LOAD_ADDR=${TEE_LOAD_ADDR} dtbs=${UBOOT_DTB} print_fit_hab 2>&1 | tee "${UBOOT_COLLECTION}"/mkimage-print_fit_hab.log || exit 1
	cp --remove-destination "${IMX_MKIMAGE_PATH}"/imx-mkimage/iMX8M/flash.bin "${UBOOT_COLLECTION}"/u-boot-"${UBOOT_PLATFORM}".imx
	build_trustfence_tools_zip "${UBOOT_PLATFORM}"
}
