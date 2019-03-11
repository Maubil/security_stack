

/***************************** Include Files *******************************/
#include "CRO_puf.h"
#include "xil_io.h"

/************************** Function Definitions ***************************/

/****************************************************************************/
/* Write CRO input values
 */
void CRO_write_inputs(CRO_puf_t *cro)
{
	if (cro->started == FALSE)
	{
		u8 i = 1;

		// write challenge
		Xil_Out32(cro->core_addr + 4 * i++, cro->challenge[0]);
		Xil_Out32(cro->core_addr + 4 * i++, cro->challenge[1]);
		Xil_Out32(cro->core_addr + 4 * i++, cro->challenge[2]);
		Xil_Out32(cro->core_addr + 4 * i++, cro->challenge[3]);

		// write control
		Xil_Out32(cro->core_addr + 4 * i++, cro->control[0]);
		Xil_Out32(cro->core_addr + 4 * i++, cro->control[1]);
		Xil_Out32(cro->core_addr + 4 * i++, cro->control[2]);

		cro->ready = TRUE;
	}
}

/****************************************************************************/
/* Reset and set enable signal on CRO core
 */
void CRO_start(CRO_puf_t *cro)
{
	if (cro->ready == TRUE && cro->started == FALSE)
	{
		// reset
		Xil_Out32(cro->core_addr, 0x2);
		Xil_Out32(cro->core_addr, 0);

		// set enable
		Xil_Out32(cro->core_addr, 0x1);
		cro->started = TRUE;
	}
}

/****************************************************************************/
/* Stop core and read back results
 */
void CRO_stop(CRO_puf_t *cro, CRO_raw_resp_t *res)
{
	if (cro->ready == TRUE && cro->started == TRUE)
	{
		res->response = Xil_In32(cro->core_addr + 40);
		res->top_out = Xil_In32(cro->core_addr + 32);
		res->bot_out = Xil_In32(cro->core_addr + 36);

		cro->started = FALSE;
	}
}