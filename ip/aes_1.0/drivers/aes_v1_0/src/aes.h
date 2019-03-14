
#ifndef AES_H
#define AES_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"

/**************************** Type Definitions *****************************/
/**
 *
 * Write/Read 32 bit value to/from AES user logic memory (BRAM).
 *
 * @param   Address is the memory address of the AES device.
 * @param   Data is the value written to user logic memory.
 *
 * @return  The data from the user logic memory.
 *
 * @note
 * C-style signature:
 * 	void AES_mWriteMemory(u32 Address, u32 Data)
 * 	u32 AES_mReadMemory(u32 Address)
 *
 */
#define AES_mWriteMemory(Address, Data) \
    Xil_Out32(Address, (u32)(Data))
#define AES_mReadMemory(Address) \
    Xil_In32(Address)

typedef enum {
	AES_128_BIT_KEY = 0,
	AES_256_BIT_KEY,
    AES_KEY_ERROR
} key_length_t;

typedef enum {
	AES_DECIPHER = 0,
	AES_ENCIPHER,
    AES_CIPHER_ERROR
} cipher_mode_t;

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the AESinstance to be worked on.
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
XStatus AES_SelfTest(void * baseaddr_p);

void aes_set_addr(u32 addr);
XStatus aes_init_key(const u32 *key, const key_length_t key_length);
XStatus aes(const u32 input_data[4], u32 result[4], key_length_t key_length, cipher_mode_t encdec);

#endif // AES_H
