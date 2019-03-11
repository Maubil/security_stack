

/***************************** Include Files *******************************/
#include "puf.h"
#include "xil_io.h"

/************************** Function Definitions ***************************/

/****************************************************************************/
/* Write puf input values
 */
void puf_write_inputs(puf_t *puf)
{
	if (puf->started == FALSE)
	{
		// write challenge
		Xil_Out32(puf->core_addr + 4, puf->challenge[0]);
		Xil_Out32(puf->core_addr + 8, puf->challenge[1]);
		Xil_Out32(puf->core_addr + 12, puf->challenge[2]);
		Xil_Out32(puf->core_addr + 16, puf->challenge[3]);

		puf->ready = TRUE;
	}
}

/****************************************************************************/
/* Reset and set enable signal on puf core
 */
void puf_start(puf_t *puf)
{
	if (puf->ready == TRUE && puf->started == FALSE)
	{
		// reset
		Xil_Out32(puf->core_addr, 0x2);
		Xil_Out32(puf->core_addr, 0);

		// set enable
		Xil_Out32(puf->core_addr, 0x1);
		Xil_Out32(puf->core_addr, 0);
		puf->started = TRUE;
	}
}

/****************************************************************************/
/* Stop core and read back results
 */
void puf_stop(puf_t *puf, u32 *res)
{
	if (puf->ready == TRUE && puf->started == TRUE)
	{
		*res = Xil_In32(puf->core_addr + 20);

		puf->started = FALSE;
	}
}