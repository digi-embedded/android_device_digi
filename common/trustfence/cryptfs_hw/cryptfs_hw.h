/*
 * Copyright 2016-2020 Digi International Inc., All Rights Reserved
 *
 * This software contains proprietary and confidential information of Digi
 * International Inc.  By accepting transfer of this copy, Recipient agrees
 * to retain this software in confidence, to prevent disclosure to others,
 * and to make no use of this software other than that for which it was
 * delivered.  This is an unpublished copyrighted work of Digi International
 * Inc.  Except as permitted by federal law, 17 USC 117, copying is strictly
 * prohibited.
 *
 * Restricted Rights Legend
 *
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in sub-paragraph (c)(1)(ii) of The Rights in
 * Technical Data and Computer Software clause at DFARS 252.227-7031 or
 * subparagraphs (c)(1) and (2) of the Commercial Computer Software -
 * Restricted Rights at 48 CFR 52.227-19, as applicable.
 *
 * Digi International Inc., 9350 Excelsior Blvd., Suite 700, Hopkins, MN 55343
 */

#ifndef CRYPTFS_HW_H
#define CRYPTFS_HW_H

#ifdef __cplusplus
extern "C" {
#endif

#define KEYSIZE_BYTES	32 /* 256 bits */

/* Parameters need to be properly allocated */
int caam_decrypt_master_key(unsigned char *encrypted_master_key,
			    unsigned char *decrypted_master_key);

/*
 * master_key: minimum 48 bytes allocated (for struct crypt_mnt_ftr)
 */
int create_caam_encrypted_random_key(unsigned char *master_key);

int verify_base64_password(char *passwd2verify);

#ifdef __cplusplus
}
#endif

#endif
