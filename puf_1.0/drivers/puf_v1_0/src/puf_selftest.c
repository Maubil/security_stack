
/***************************** Include Files *******************************/
#include <stdlib.h>
#include "puf.h"
#include "xil_io.h"

/************************** Constant Definitions ***************************/
#define READ_WRITE_MUL_FACTOR 0x10

/************************** Function Definitions ***************************/
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
XStatus PUF_Mem_SelfTest(void * baseaddr_p)
{
	int     Index;
	u32 baseaddr;
	u32 Mem32Value;

	baseaddr = (u32) baseaddr_p;

	xil_printf("******************************\n\r");
	xil_printf("* User Peripheral Self Test\n\r");
	xil_printf("******************************\n\n\r");

	/*
	 * Write data to user logic BRAMs and read back
	 */
	xil_printf("User logic memory test...\n\r");
	xil_printf("   - local memory address is 0x%08x\n\r", baseaddr);
	xil_printf("   - write pattern to local BRAM and read back\n\r");
	for ( Index = 0; Index < 16; Index++ )
	{
	  PUF_mWriteMemory(baseaddr+4*Index, (0xDEADBEEF % Index));
	}

	for ( Index = 0; Index < 16; Index++ )
	{
	  Mem32Value = PUF_mReadMemory(baseaddr+4*Index);
	  if ( Mem32Value != (0xDEADBEEF % Index) )
	  {
	    xil_printf("   - write/read memory failed on address 0x%08x\n\r", baseaddr+4*Index);
	    return XST_FAILURE;
	  }
	}
	xil_printf("   - write/read memory passed\n\n\r");

	return XST_SUCCESS;
}


/****************************************************************************/
/* Run puf test vector
 * input_parameters: filled out input parameters
 * run_results: array containing basic informations about the run
 * run_results_len: number of runs
 * fp: function pointer to a sleep function (allows the user to use other functions like usleep, ... to have a more granular control over the time)
 * time_unit: string containing the unit of time being in use. e.g.: 'minutes', 'seconds' ...
 */
void puf_test_vector(puf_t input_parameters, puf_runs_t run_results[], size_t nb_runs, sleep_callback fp, const char *time_unit)
{
	puf_write_inputs(&input_parameters);

	u32 total_time = 0;
	for(size_t i = 0; i < nb_runs; i++)
	{
		run_results[i].response = calloc(0, sizeof(u32) * run_results[i].nb_runs);
		if(run_results[i].response == NULL)
		{
			xil_printf("[puf] calloc error! Deallocating NOW and terminating!\n\r");
			for(size_t j = 0; j < i; j++) // deallocate previously allocated memory
			{
				free(run_results[j].response);
			}
			return;
		}
		total_time += (run_results[i].time * run_results[i].nb_runs);
	}

	xil_printf("[puf] Starting NOW! Expected duration is %u %s!\n\r", total_time, time_unit);
	xil_printf("[puf] Challenge is 0x%08x %08x %08x %08x\n\r", input_parameters.challenge[3], input_parameters.challenge[2], input_parameters.challenge[1], input_parameters.challenge[0]);

	// number of runs for each timing group
	for(size_t i = 0; i < nb_runs; i++)
	{
		// run each timing run_results[i].nb_runs times
		for(size_t j = 0; j < run_results[i].nb_runs; j++)
		{
			puf_start(&input_parameters);
			fp(run_results[i].time);
			puf_stop(&input_parameters, &run_results[i].response[j]);
			xil_printf("[puf] Run %u --- delay of %u s --- response is 0x%08x\n\r", (i*run_results[i].nb_runs)+j, run_results[i].time, run_results[i].response[j]);
		}
	}

	for(size_t i = 0; i < nb_runs; i++)
	{
		free(run_results[i].response);
	}

	xil_printf("[puf] All Done!\n\r");
}