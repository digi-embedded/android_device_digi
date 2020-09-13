Secure boot support
~~~~~~~~~~~~~~~~~~~

Digi Embedded for Android (DEA) uses NXP's Code signing Tool (CST) for the
High Assurance Boot library when generating secure firmware images. You must
download the CST tool and unpack it into this directory. Also, some patches
need to be applied before using it.

Basic instructions:

# cd <DEA-INSTALL-DIR>/device/digi/common/trustfence/cst
# tar --transform="s,^release,cst-3.1.0," -x -f cst-3.1.0.tgz
# cd cst-3.1.0
# for i in ../patch/*.patch; do patch -p1 < $i; done

If the tool is not found DEA TrustFence build will fail.

