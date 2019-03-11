
#ifndef PUF_H
#define PUF_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"


/**************************** Type Definitions *****************************/
/**
 *
 * Write/Read 32 bit value to/from PUF user logic memory (BRAM).
 *
 * @param   Address is the memory address of the PUF device.
 * @param   Data is the value written to user logic memory.
 *
 * @return  The data from the user logic memory.
 *
 * @note
 * C-style signature:
 * 	void PUF_mWriteMemory(u32 Address, u32 Data)
 * 	u32 PUF_mReadMemory(u32 Address)
 *
 */
#define PUF_mWriteMemory(Address, Data) \
    Xil_Out32(Address, (u32)(Data))
#define PUF_mReadMemory(Address) \
    Xil_In32(Address)


/**************************** Struct Definitions *****************************/
typedef struct {
    u32 core_addr;
	u32 challenge[4];
	u8 ready;
	u8 started;
}puf_t;

typedef struct {
	u32 *response;
	size_t nb_runs;
	u32 time;
}puf_runs_t;

typedef void (*sleep_callback)(unsigned int);

/************************** Function Prototypes ****************************/
/**
 *
 * Run a self-test on the driver/device. Note this may be a destructive test if
 * resets of the device are performed.
 *
 * If the hardware system is not built correctly, this function may never
 * return to the caller.
 *
 * @param   baseaddr_p is the base address of the PUFinstance to be worked on.
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
XStatus PUF_Mem_SelfTest(void * baseaddr_p);
void puf_test_vector(puf_t input_parameters, puf_runs_t run_results[], size_t nb_runs, sleep_callback fp, const char *time_unit);

void puf_write_inputs(puf_t *puf);
void puf_start(puf_t *puf);
void puf_stop(puf_t *puf, u32 *res);

#endif // PUF_H
