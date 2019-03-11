

/***************************** Include Files *******************************/
#include "securePUF.h"
#include "xil_io.h"

/************************** Function Definitions ***************************/

/****************************************************************************/
/* Write CRO input values
 */
void securePUF_write_inputs(securePUF_t *securePUF)
{
	if (securePUF->started == FALSE)
	{
		// write challenge
		Xil_Out32(securePUF->core_addr + 4, securePUF->challenge);

		// write pdl_config
		Xil_Out32(securePUF->core_addr + 8, securePUF->pdl_config[0]);
		Xil_Out32(securePUF->core_addr + 12, securePUF->pdl_config[1]);
		Xil_Out32(securePUF->core_addr + 16, securePUF->pdl_config[2]);
        Xil_Out32(securePUF->core_addr + 20, securePUF->pdl_config[3]);

		securePUF->ready = TRUE;
	}
}

/****************************************************************************/
/* Reset and set enable signal on CRO core
 */
void securePUF_start(securePUF_t *securePUF)
{
	if (securePUF->ready == TRUE && securePUF->started == FALSE)
	{
		// reset
		Xil_Out32(securePUF->core_addr, 0x2);
		Xil_Out32(securePUF->core_addr, 0);

		// set enable
		Xil_Out32(securePUF->core_addr, 0x1);
        Xil_Out32(securePUF->core_addr, 0);
		securePUF->started = TRUE;
	}
}

/****************************************************************************/
/* Stop core and read back results
 */
void securePUF_stop(securePUF_t *securePUF, u32 *res)
{
	if (securePUF->ready == TRUE && securePUF->started == TRUE)
	{
		*res = Xil_In32(securePUF->core_addr + 24);
		securePUF->started = FALSE;
	}
}