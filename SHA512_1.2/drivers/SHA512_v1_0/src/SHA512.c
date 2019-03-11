/*
 * Description: Driver for the SHA512 core
 * 
 * Author: Maurice Billmann
 * Date: December 2018
 * 
 */

/***************************** Include Files *******************************/
#include "SHA512.h"
#include "xil_io.h"
#include "xstatus.h"
#include "sleep.h"

/************************** Global Definitions ***************************/
#define ADDR_NAME0           ((0x00)*4)
#define ADDR_NAME1           ((0x01)*4)
#define ADDR_VERSION         ((0x02)*4)
#define ADDR_CTRL            ((0x08)*4)
#define ADDR_STATUS          ((0x09)*4)
#define ADDR_WORK_FACTOR_NUM ((0x0a)*4)
#define ADDR_BLOCK0          ((0x10)*4)
#define ADDR_DIGEST0         ((0x30)*4)

#define CTRL_INIT_BIT        (0)
#define CTRL_NEXT_BIT        (1)
#define CTRL_MODE_LOW_BIT    (2)
#define CTRL_MODE_HIGH_BIT   (3)
#define CTRL_WORK_FACTOR_BIT (7)

#define STATUS_READY_BIT     (0)
#define STATUS_VALID_BIT     (1)

/************************** Structure Definitions ***************************/
typedef struct {
	u8 init : 1;
	u8 next : 1;
	sha512_mode_t mode : 2;
	/* the core works with other work factors, if you REALLY know what you are
	 * doing, set this to 1 and write your custom work factor to the right*/
	u8 work_factor : 1;
} sha512_ctrl_t;

/************************** Private variables ***************************/
static u32 ip_core_addr = 0;
static char core_info[14] = {};
static sha512_ctrl_t internal_ctrl = {};

/************************** Prototype definition ***************************/
static XStatus write_ctrl(sha512_ctrl_t *ctrl);
static void wait_until_ready(void);
static XStatus wait_until_valid(void);

/************************** Public functions ***************************/
void sha512_set_addr(u32 addr)
{
	ip_core_addr = addr;

	/* fetch ip core information */
	core_info[0] = Xil_In8(ip_core_addr + ADDR_NAME0 + 3);
	core_info[1] = Xil_In8(ip_core_addr + ADDR_NAME0 + 2);
	core_info[2] = Xil_In8(ip_core_addr + ADDR_NAME0 + 1);
	core_info[3] = Xil_In8(ip_core_addr + ADDR_NAME0 + 0);

	core_info[4] = Xil_In8(ip_core_addr + ADDR_NAME1 + 3);
	core_info[5] = Xil_In8(ip_core_addr + ADDR_NAME1 + 2);
	core_info[6] = Xil_In8(ip_core_addr + ADDR_NAME1 + 1);
	core_info[7] = Xil_In8(ip_core_addr + ADDR_NAME1 + 0);

	core_info[8] = ' ';

	core_info[9] = Xil_In8(ip_core_addr + ADDR_VERSION + 3);
	core_info[10] = Xil_In8(ip_core_addr + ADDR_VERSION + 2);
	core_info[11] = Xil_In8(ip_core_addr + ADDR_VERSION + 1);
	core_info[12] = Xil_In8(ip_core_addr + ADDR_VERSION + 0);
}

const char *sha512_get_core_info(void)
{
	return core_info;
}

/* use this only if you REALLY know what you are doing!!!
 * set your custom work factor here
 * needs to be called AFTER sha512_init() !!
 * -> resets to default after calling sha512_set_addr() or performing a system reset */
XStatus sha512_custom_work_factor(u32 work_factor)
{
	if(ip_core_addr == 0)
	{
		xil_printf("No address!!\n");
		return XST_FAILURE;
	}

	Xil_Out32(ip_core_addr + ADDR_WORK_FACTOR_NUM, work_factor);

	internal_ctrl.work_factor = 1;
	return XST_SUCCESS;
}

/* should only be used if at any point you called sha512_custom_work_factor() */
void sha512_default_work_factor(void)
{
	internal_ctrl.work_factor = 0;
}

XStatus sha512_second_round(const u32 block[32])
{
	if(ip_core_addr == 0)
	{
		xil_printf("No address!!\n");
		return XST_FAILURE;
	}

    for (size_t i = 0; i < 32; i++)
    {
    	Xil_Out32(ip_core_addr + ADDR_BLOCK0 + i*4, block[i]);
    }

	wait_until_ready();

    internal_ctrl.init = 0;
    internal_ctrl.next = 1;
    XStatus rc = write_ctrl(&internal_ctrl);
    if (rc != XST_SUCCESS)
    {
    	return rc;
    }

    internal_ctrl.next = 0;
    return write_ctrl(&internal_ctrl);
}

XStatus sha512_first_round(const u32 block[32], const sha512_mode_t mode)
{
	if(ip_core_addr == 0)
	{
		xil_printf("No address!!\n");
		return XST_FAILURE;
	}

    if (block == NULL)
    {
    	xil_printf("NULL pointer!!\n");
        return XST_FAILURE;
    }

    for (size_t i = 0; i < 32; i++)
    {
    	Xil_Out32(ip_core_addr + ADDR_BLOCK0 + i*4, block[i]);
    }

    wait_until_ready();

    internal_ctrl.mode = mode;
    internal_ctrl.next = 0;
    internal_ctrl.init = 1;
    XStatus rc = write_ctrl(&internal_ctrl);
    if (rc != XST_SUCCESS)
    {
    	return rc;
    }

    internal_ctrl.init = 0;
    return write_ctrl(&internal_ctrl);
}

XStatus sha512_read_block(u32 block[32])
{
	if(ip_core_addr == 0)
	{
		xil_printf("No address!!\n");
		return XST_FAILURE;
	}

    if (block == NULL)
    {
    	xil_printf("NULL pointer!!\n");
        return XST_FAILURE;
    }

    for (size_t i = 0; i < 32; i++)
    {
    	block[i] = Xil_In32(ip_core_addr + ADDR_BLOCK0 + i*4);
    }

    return XST_SUCCESS;
}

XStatus sha512_read_digest(u32 digest[16])
{
	if(ip_core_addr == 0)
	{
		xil_printf("No address!!\n");
		return XST_FAILURE;
	}

    if (digest == NULL)
    {
    	xil_printf("NULL pointer!!\n");
        return XST_FAILURE;
    }

    wait_until_valid();

    for (size_t i = 0; i < 32; i++)
    {
    	digest[i] = Xil_In32(ip_core_addr + ADDR_DIGEST0 + i*4);
    }

    return XST_SUCCESS;
}

/************************** Private function definitions ***************************/
static XStatus write_ctrl(sha512_ctrl_t *ctrl)
{
	if(ip_core_addr == 0)
	{
		xil_printf("No address!!\n");
		return XST_FAILURE;
	}

    if (ctrl == NULL)
    {
    	xil_printf("NULL pointer!!\n");
        return XST_FAILURE;
    }

    u32 tmp = ctrl->init & 0x00000001;
    tmp |= ((ctrl->next << CTRL_NEXT_BIT) & 0x2);
    tmp |= ((ctrl->mode << CTRL_MODE_LOW_BIT) & 0xC);
    tmp |= ((ctrl->work_factor << CTRL_WORK_FACTOR_BIT) & 0x80);
    Xil_Out32(ip_core_addr + ADDR_CTRL, tmp);

    return XST_SUCCESS;
}

static void wait_until_ready(void)
{
	while(((Xil_In32(ip_core_addr + ADDR_STATUS) >> STATUS_READY_BIT) & 0x1) != 0x1);
}

static XStatus wait_until_valid(void)
{
	while(((Xil_In32(ip_core_addr + ADDR_STATUS) >> STATUS_VALID_BIT) & 0x1) != 0x1);
}

