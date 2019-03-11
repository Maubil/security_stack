
#ifndef SECUREPUF_H
#define SECUREPUF_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"

/**************************** Type Definitions *****************************/
/**
 *
 * Write/Read 32 bit value to/from SECUREPUF user logic memory (BRAM).
 *
 * @param   Address is the memory address of the SECUREPUF device.
 * @param   Data is the value written to user logic memory.
 *
 * @return  The data from the user logic memory.
 *
 * @note
 * C-style signature:
 * 	void SECUREPUF_mWriteMemory(u32 Address, u32 Data)
 * 	u32 SECUREPUF_mReadMemory(u32 Address)
 *
 */
#define SECUREPUF_mWriteMemory(Address, Data) \
    Xil_Out32(Address, (u32)(Data))
#define SECUREPUF_mReadMemory(Address) \
    Xil_In32(Address)

/**************************** Struct Definitions *****************************/
typedef struct {
    u32 core_addr;
	u32 challenge;
	u32 pdl_config[4];
	u8 ready;
	u8 started;
}securePUF_t;

typedef struct {
	u32 *response;
    size_t nb_runs;
	u32 time;
}securePUF_runs_t;

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
 * @param   baseaddr_p is the base address of the SECUREPUFinstance to be worked on.
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
XStatus SECUREPUF_Mem_SelfTest(void * baseaddr_p);
void securePUF_test_vector(securePUF_t input_parameters, securePUF_runs_t run_results[], size_t run_results_len, sleep_callback fp, const char *time_unit);

void securePUF_write_inputs(securePUF_t *securePUF);
void securePUF_start(securePUF_t *securePUF);
void securePUF_stop(securePUF_t *securePUF, u32 *res);

#endif // SECUREPUF_H
