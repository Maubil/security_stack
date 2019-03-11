
#ifndef CRO_PUF_H
#define CRO_PUF_H


/****************** Include Files ********************/
#include "xil_types.h"
#include "xstatus.h"


#define NB_SINGLE_TEST_RUNS    100


/**************************** Type Definitions *****************************/
/**
 *
 * Write/Read 32 bit value to/from CRO_PUF user logic memory (BRAM).
 *
 * @param   Address is the memory address of the CRO_PUF device.
 * @param   Data is the value written to user logic memory.
 *
 * @return  The data from the user logic memory.
 *
 * @note
 * C-style signature:
 * 	void CRO_PUF_mWriteMemory(u32 Address, u32 Data)
 * 	u32 CRO_PUF_mReadMemory(u32 Address)
 *
 */
#define CRO_PUF_mWriteMemory(Address, Data) \
    Xil_Out32(Address, (u32)(Data))
#define CRO_PUF_mReadMemory(Address) \
    Xil_In32(Address)


/**************************** Struct Definitions *****************************/
typedef struct {
    u32 core_addr;
	u32 challenge[4];
	u32 control[3];
	u8 ready;
	u8 started;
}CRO_puf_t;

typedef struct {
	u32 response;
	u32 top_out;
	u32 bot_out;
}CRO_raw_resp_t;

typedef struct {
	CRO_raw_resp_t *response;
	size_t nb_runs;
	u32 time;
}CRO_runs_t;

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
 * @param   baseaddr_p is the base address of the CRO_PUFinstance to be worked on.
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
XStatus CRO_PUF_Mem_SelfTest(void * baseaddr_p);
void CRO_test_vector(CRO_puf_t input_parameters, CRO_runs_t run_results[], size_t nb_runs, sleep_callback fp, const char *time_unit);

void CRO_write_inputs(CRO_puf_t *cro);
void CRO_start(CRO_puf_t *cro);
void CRO_stop(CRO_puf_t *cro, CRO_raw_resp_t *res);

#endif // CRO_PUF_H
