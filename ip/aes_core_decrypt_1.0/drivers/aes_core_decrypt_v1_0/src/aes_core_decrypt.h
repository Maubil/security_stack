
#ifndef AES_CORE_DECRYPT_H
#define AES_CORE_DECRYPT_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"


/**************************** Type Definitions *****************************/
/**
 *
 * Write/Read 32 bit value to/from AES_CORE_DECRYPT user logic memory (BRAM).
 *
 * @param   Address is the memory address of the AES_CORE_DECRYPT device.
 * @param   Data is the value written to user logic memory.
 *
 * @return  The data from the user logic memory.
 *
 * @note
 * C-style signature:
 * 	void AES_CORE_DECRYPT_mWriteMemory(u32 Address, u32 Data)
 * 	u32 AES_CORE_DECRYPT_mReadMemory(u32 Address)
 *
 */
#define AES_CORE_DECRYPT_mWriteMemory(Address, Data) \
    Xil_Out32(Address, (u32)(Data))
#define AES_CORE_DECRYPT_mReadMemory(Address) \
    Xil_In32(Address)

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the AES_CORE_DECRYPTinstance to be worked on.
 *
 * @return
 *
 *    - XST_SUCCESS   if all self-test code passed
 *    - XST_FAILURE   if any self-test code failed
 *
 * @note    Caching must be turned off for this function to work.
 * @note    Self test may fail if data memory and device are not on the same bus.
 *
 */
XStatus AES_CORE_DECRYPT_SelfTest(void * baseaddr_p);

void aes_core_decrypt_set_addr(u32 base_addr);
XStatus aes_core_decrypt_init_key(const u32 key[4]);
XStatus aes_core_decrypt(const u32 ciphertext[4], u32 plaintext[4]);

#endif // AES_CORE_DECRYPT_H
