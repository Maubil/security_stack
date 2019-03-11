/*
 * Description: Driver for the SHA512 core
 * 
 * Author: Maurice Billmann
 * Date: December 2018
 * 
 */

#ifndef SHA512_H
#define SHA512_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"


/**************************** Type Definitions *****************************/
/**
 *
 * Write/Read 32 bit value to/from SHA512 user logic memory (BRAM).
 *
 * @param   Address is the memory address of the SHA512 device.
 * @param   Data is the value written to user logic memory.
 *
 * @return  The data from the user logic memory.
 *
 * @note
 * C-style signature:
 * 	void SHA512_mWriteMemory(u32 Address, u32 Data)
 * 	u32 SHA512_mReadMemory(u32 Address)
 *
 */
#define SHA512_mWriteMemory(Address, Data) \
    Xil_Out32(Address, (u32)(Data))
#define SHA512_mReadMemory(Address) \
    Xil_In32(Address)

typedef enum {
	MODE_SHA_512_224 = (0x0),
	MODE_SHA_512_256 = (0x1),
	MODE_SHA_384     = (0x2),
	MODE_SHA_512     = (0x3)
} sha512_mode_t;

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the SHA512instance to be worked on.
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
XStatus SHA512_Mem_SelfTest(void * baseaddr_p);

void sha512_set_addr(u32 addr);
const char *sha512_get_core_info(void);
/* use this only if you REALLY know what you are doing!!!
 * set your custom work factor here
 * -> resets to default after calling sha512_set_addr() or performing a system reset */
XStatus sha512_custom_work_factor(u32 work_factor);
/* should only be used if at any point you called sha512_custom_work_factor() */
void sha512_default_work_factor(void);
XStatus sha512_second_round(const u32 block[32]);
XStatus sha512_first_round(const u32 block[32], const sha512_mode_t mode);
XStatus sha512_read_block(u32 block[32]);
XStatus sha512_read_digest(u32 digest[16]);

#endif // SHA512_H
