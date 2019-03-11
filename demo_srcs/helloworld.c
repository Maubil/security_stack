/****************************************************************************/
/* author: Maurice Billmann
 * date: 02.11.2018
 ****************************************************************************/


/*--------------------------------------------------------------------------*/
/* include files                                                            */
/*--------------------------------------------------------------------------*/
#include <stdio.h>
#include <xgpio.h>

#include "platform.h"
#include "xparameters.h"
#include "sleep.h"

#include "xil_io.h"

#define DEMO // go into DEMO mode

#define HAS_MEM_TEST			0
#define HAS_CRO_PUF				0
#define HAS_SECURE_PUF 			0
#define HAS_PUF					0
#define HAS_AES_CORE_ENCRYPT	0
#define HAS_AES_CORE_DECRYPT	0
#define HAS_AES					0
#define HAS_SHA512				1

#if HAS_CRO_PUF
#include "CRO_puf.h"
#endif
#if HAS_SECURE_PUF
#include "securePUF.h"
#endif
#if HAS_PUF
#include "puf.h"
#endif
#if HAS_AES
#include "aes.h"
#endif
#if HAS_AES_CORE_ENCRYPT
#include "aes_core_encrypt.h"
#endif
#if HAS_AES_CORE_DECRYPT
#include "aes_core_decrypt.h"
#endif
#if HAS_SHA512
#include "SHA512.h"
#endif

/*--------------------------------------------------------------------------*/
/* general definitions (private/not exported)                               */
/*--------------------------------------------------------------------------*/
#define LOOP_DELAY			200
#define PRINT_DATA(x, type)		xil_printf("Printing "#x":\t"); print_data_block((u32 *)x, sizeof(x)/sizeof(x[0]))

/*--------------------------------------------------------------------------*/
/* structure/type definitions (private/not exported)                        */
/*--------------------------------------------------------------------------*/
typedef struct {
	const char *test_name;
	int (*test)(int);
} test_struct_t;

/*--------------------------------------------------------------------------*/
/* global variables (public/exported)                                       */
/*--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/* global variables (private/not exported)                                  */
/*--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/* function prototypes (private/not exported)                               */
/*--------------------------------------------------------------------------*/
#ifdef DEMO
extern int main2();
#endif
static void read_write_addr(u32 addr, u32 value);
static void register_test(u32 base_addr, u32 button_data);
static void print_data_block(u32 *data, size_t len);

int test0(int btn)
{
#if HAS_MEM_TEST
	register_test(XPAR_MEM_TEST_0_S00_AXI_BASEADDR, btn);
#endif
	return 0;
}
int test1(int btn)
{
#if HAS_CRO_PUF
	register_test(XPAR_CRO_PUF_0_S00_AXI_BASEADDR, btn);
#endif
	return 0;
}
int test2(int btn)
{
#if HAS_SECURE_PUF
  register_test(XPAR_SECUREPUF_0_S00_AXI_BASEADDR, btn);
#endif
  return 0;
}
int test3(int btn)
{
#if HAS_PUF
  register_test(XPAR_PUF_0_S00_AXI_BASEADDR, btn);
#endif
  return 0;
}
int test4(int btn)
{
#if HAS_CRO_PUF
	CRO_puf_t cro = {
			.core_addr = XPAR_CRO_PUF_0_S00_AXI_BASEADDR,
			.challenge = {0xBADC0FFE, 0xBADC0FFE, 0xBADC0FFE, 0xBADC0FFE},
			.control = {0x99999999, 0x99999999, 0x99999999},
			.ready = FALSE,
			.started = FALSE
	};

	CRO_runs_t cro_res[] = {
		   {.response = NULL, .time = 10, .nb_runs = 1},
		   {.response = NULL, .time = 20, .nb_runs = 1},
		   {.response = NULL, .time = 30, .nb_runs = 1},
		   {.response = NULL, .time = 40, .nb_runs = 1}
	};
	if (btn == 0b0001)
	{
		CRO_test_vector(cro, cro_res, sizeof(cro_res)/sizeof(cro_res[0]), &sleep, "seconds");
	}
#endif
	return 0;
}
int test5(int btn)
{
#if HAS_SECURE_PUF
	securePUF_t sec_puf = {
			.core_addr = XPAR_SECUREPUF_0_S00_AXI_BASEADDR,
			.challenge = 0x123465AA,
			.pdl_config = {0x99999999, 0x99999999, 0x99999999, 0x99999999},
			.ready = FALSE,
			.started = FALSE
	};

	securePUF_runs_t sec_puf_runs[] = {
		   {.response = NULL, .time = 10, .nb_runs = 3}
	};
	if (btn == 0b0001)
	{
		securePUF_test_vector(sec_puf, sec_puf_runs, sizeof(sec_puf_runs)/sizeof(sec_puf_runs[0]), &sleep, "seconds");
	}
#endif
	return 0;
}

int test6(int btn)
{
#if HAS_PUF
	puf_t puf_core = {
			.core_addr = XPAR_PUF_0_S00_AXI_BASEADDR,
			.challenge = {0xBADC0FFE, 0xBADC0FFE, 0xBADC0FFE, 0xBADC0FFE},
			.ready = FALSE,
			.started = FALSE
	};

	puf_runs_t puf_core_runs[] = {
		   {.response = NULL, .time = 10, .nb_runs = 10},
		   {.response = NULL, .time = 20, .nb_runs = 10},
		   {.response = NULL, .time = 30, .nb_runs = 10},
		   {.response = NULL, .time = 40, .nb_runs = 10}
	};
	if (btn == 0b0001)
	{
		puf_test_vector(puf_core, puf_core_runs, sizeof(puf_core_runs)/sizeof(puf_core_runs[0]), &sleep, "seconds");
	}
#endif
	return 0;
}
int test7(int btn)
{
#if HAS_AES_CORE_ENCRYPT
	if (btn == 0b0001)
	{
		AES_CORE_ENCRYPT_SelfTest((void *)XPAR_AES_CORE_ENCRYPT_0_S00_AXI_BASEADDR);
	}
#endif
#if HAS_AES_CORE_DECRYPT
	if (btn == 0b0010)
	{
		AES_CORE_DECRYPT_SelfTest((void *)XPAR_AES_CORE_DECRYPT_0_S00_AXI_BASEADDR);
	}
#endif
#if HAS_AES
	if (btn == 0b0100)
	{
		AES_SelfTest((void *)XPAR_AES_0_S00_AXI_BASEADDR);
	}
#endif
	return 0;
}
int test8(int btn)
{
#if HAS_SHA512
	if (btn == 0b0001)
	{
		sha512_set_addr(XPAR_SHA512_0_S00_AXI_BASEADDR);
		xil_printf("Core is %s\n\r", sha512_get_core_info());

		u32 block[32] = {0x61626364, 0x65666768, 0x62636465, 0x66676869, 0x63646566, 0x6768696A, 0x64656667, 0x68696A6B,
				0x65666768, 0x696A6B6C, 0x66676869, 0x6A6B6C6D, 0x6768696A, 0x6B6C6D6E, 0x68696A6B, 0x6C6D6E6F,
				0x696A6B6C, 0x6D6E6F70, 0x6A6B6C6D, 0x6E6F7071, 0x6B6C6D6E, 0x6F707172, 0x6C6D6E6F, 0x70717273,
				0x6D6E6F70, 0x71727374, 0x6E6F7071, 0x72737475, 0x80000000, 0x00000000, 0x00000000, 0x00000000};

		u32 second_block[32] = {0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
				0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
				0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
				0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000380};

		u32 third_block[32] = {};
		third_block[0] = 0x61626300;

		PRINT_DATA(block, sizeof(u32));


		sha512_custom_work_factor(0);
		sha512_first_round(block, MODE_SHA_512_224);

		u32 res[16] = {};
		sha512_read_digest(res);
		PRINT_DATA(res, sizeof(u32));

		sha512_second_round(second_block);
		sha512_read_digest(res);
		PRINT_DATA(res, sizeof(u32));

		sha512_first_round(third_block, MODE_SHA_512);
		sha512_read_digest(res);
		PRINT_DATA(res, sizeof(u32));
	}
#endif
	return 0;
}


static test_struct_t test_vector[] = {
		{"Test the registers of the mem_test core\n\r", test0},
		{"Test the registers of the CRO_puf core\n\r", test1},
		{"Test the registers of the securePUF core\n\r", test2},
		{"Test the registers of the puf core\n\r", test3},
		{"Run CRO_puf test vector\n\r", test4},
		{"Run securePUF test vector\n\r", test5},
		{"Run puf test vector\n\r", test6},
		{"Test AES core\n\r", test7},
		{"Test SHA core\n\r", test8}
};

/*--------------------------------------------------------------------------*/
/* function definition (public/exported)                                    */
/*--------------------------------------------------------------------------*/
int main()
{
#ifdef DEMO
	return main2();
#endif
   XGpio input, output;
   int button_data = 0;
   int switch_data = 0;
   int prev_switch_data = 0;

   XGpio_Initialize(&input, XPAR_AXI_GPIO_0_DEVICE_ID);	//initialize input XGpio variable
   XGpio_Initialize(&output, XPAR_AXI_GPIO_1_DEVICE_ID);	//initialize output XGpio variable

   XGpio_SetDataDirection(&input, 1, 0xF);			//set first channel tristate buffer to input
   XGpio_SetDataDirection(&input, 2, 0xF);			//set second channel tristate buffer to input

   XGpio_SetDataDirection(&output, 1, 0x0);		//set first channel tristate buffer to output

   init_platform();

   xil_printf("\n\r========================================================================\n\r");
   xil_printf("System started properly with binary compiled on %s at %s\n\r\n\r", __DATE__, __TIME__);

   size_t test_vector_len = sizeof(test_vector) / sizeof(test_vector[0]);

   while(1)
   {
      switch_data = XGpio_DiscreteRead(&input, 2);	//get switch data

      if(switch_data != prev_switch_data)
      {
    	  if(switch_data < test_vector_len)
    	  {
    		  xil_printf(test_vector[switch_data].test_name);
    	  }
    	  else
    	  {
    		  xil_printf("No test associated\n\r");
    	  }
    	  prev_switch_data = switch_data;
      }

      XGpio_DiscreteWrite(&output, 1, switch_data);	//write switch data to the LEDs

      button_data = XGpio_DiscreteRead(&input, 1);	//get button data

	  if(switch_data < test_vector_len)
	  {
		  test_vector[switch_data].test(button_data);
	  }

      usleep(LOOP_DELAY * 1000);
   }

   cleanup_platform();
   return 0;
}

/*--------------------------------------------------------------------------*/
/* function definition (private/not exported)                               */
/*--------------------------------------------------------------------------*/

/****0x********, ****************************************************************/
/* Write and read back value at given address
 */
static void read_write_addr(u32 addr, u32 value)
{
	Xil_Out32(addr, value);
	xil_printf("Read value 0x%08x\n\r", Xil_In32(addr));
}

static void print_data_block(u32 *data, size_t len)
{
	u32 *tmp = data;
	for (size_t i = 0; i < len; i++)
	{
		if(i%4 == 0 && i != 0)
			xil_printf("\n\r\t\t");

		xil_printf("0x%08x ", *tmp);
		tmp++;
	}
	xil_printf("\n\r\n\r");
}

/****************************************************************************/
/* Read Write test based on a base address
 * Using the buttons on the board, the register can be selected, written and read back
     * BTN3: READ VALUE
     * BTN2: WRITE VALUE
     * BTN1: NEXT REG
     * BTN0: PREV REG
 */
static void register_test(u32 base_addr, u32 button_data)
{
	static u16 active_reg = 0;

    switch(button_data)
    {
    case 0b0000:
  	  break;
    case 0b0001:
  	  if (active_reg - 0x4 > 0)
  	  {
  		  active_reg -= 0x4;
  	  }
  	  else
  	  {
  		  xil_printf("Reached minimal address\n\r");
  	  }
  	  xil_printf("Memory address 0x%04x selected (IP offset is 0x%08x)\n\r", active_reg, base_addr);
  	  break;
    case 0b0010:
  	  // Addresses are mapped to bytes (8bit)
  	  // But we are retrieving 32bits in one read so move to the next 32bit region -> +4.
  	  if(active_reg + 0x4 < UINT16_MAX - 1)
  	  {
  		  active_reg += 0x4;
  	  }
  	  else
  	  {
  		  xil_printf("Reached maximal address\n\r");
  	  }
  	  xil_printf("Memory address 0x%04x selected (IP offset is 0x%08x)\n\r", active_reg, base_addr);
  	  break;
    case 0b0100:
  	  Xil_Out32(base_addr + active_reg, 0xACDC0000 | active_reg);
  	  xil_printf("Just wrote 0x%08x into memory @ address 0x%08x\n\r", 0xACDC0000 | active_reg, base_addr + active_reg);
  	  break;
    case 0b1000:
  	  xil_printf("Reading address 0x%08x => 0x%08x\n\r", base_addr + active_reg, Xil_In32(base_addr + active_reg));
  	  break;
    default:
  	  xil_printf("multiple buttons pressed\n\r");
  	  read_write_addr(base_addr + 16, 0xBAADBABE);
  	  break;
    }
}
