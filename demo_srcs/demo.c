/****************************************************************************/
/* author: Maurice Billmann
 * date: 10.01.2019
 ****************************************************************************/

/*--------------------------------------------------------------------------*/
/* include files                                                            */
/*--------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <xgpio.h>

#include "platform.h"
#include "xparameters.h"
#include "sleep.h"
#include "xil_io.h"

#include "CRO_puf.h"
#include "securePUF.h"
#include "aes.h"
#include "SHA512.h"

#include "custom_io.h"


/*--------------------------------------------------------------------------*/
/* general definitions (private/not exported)                               */
/*--------------------------------------------------------------------------*/
#define LOOP_DELAY				((unsigned long)50)

/*--------------------------------------------------------------------------*/
/* structure/type definitions (private/not exported)                        */
/*--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/* global variables (public/exported)                                       */
/*--------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------*/
/* global variables (private/not exported)                                  */
/*--------------------------------------------------------------------------*/
static XGpio input, output;

/*--------------------------------------------------------------------------*/
/* function prototypes (private/not exported)                               */
/*--------------------------------------------------------------------------*/
static int get_button_data_BLOCKING(void);
static void print_help(void);
static void DEMO_SHA512_only(void);
static void DEMO_CRO_puf_only(void);
static void DEMO_AES_only(void);
static void DEMO_RNG_only(void);

/*--------------------------------------------------------------------------*/
/* function definition (public/exported)                                    */
/*--------------------------------------------------------------------------*/
int main2()
{
	   int button_data = 0;
	   int switch_data = 0;

	   XGpio_Initialize(&input, XPAR_AXI_GPIO_0_DEVICE_ID);	//initialize input XGpio variable
	   XGpio_Initialize(&output, XPAR_AXI_GPIO_1_DEVICE_ID);//initialize output XGpio variable

	   XGpio_SetDataDirection(&input, 1, 0xF);	//set first channel tristate buffer to input
	   XGpio_SetDataDirection(&input, 2, 0xF);	//set second channel tristate buffer to input
	   XGpio_SetDataDirection(&output, 1, 0x0);	//set first channel tristate buffer to output

	   init_platform();

	   sha512_set_addr(XPAR_SHA512_0_S00_AXI_BASEADDR);
	   aes_set_addr(XPAR_AES_0_S00_AXI_BASEADDR);

	   xil_printf("\n\r========================================================================\n\r");
	   xil_printf("System started properly with binary compiled on %s at %s\n\r\n\r", __DATE__, __TIME__);

	   print_help();

	   while(1)
	   {
	      switch_data = XGpio_DiscreteRead(&input, 2);	//get switch data
	      button_data = XGpio_DiscreteRead(&input, 1);	//get button data

		  switch (button_data) {
			case 0b0001:
				while(XGpio_DiscreteRead(&input, 1) != 0); // wait on button release
				DEMO_SHA512_only();
				break;
			case 0b0010:
				while(XGpio_DiscreteRead(&input, 1) != 0);
				DEMO_CRO_puf_only();
				break;
			case 0b0100:
				while(XGpio_DiscreteRead(&input, 1) != 0);
				DEMO_AES_only();
				break;
			case 0b1000:
				while(XGpio_DiscreteRead(&input, 1) != 0);
				DEMO_RNG_only();
				break;
			default:
				break;
		  }

	      XGpio_DiscreteWrite(&output, 1, switch_data);	//write switch data to the LEDs
	      usleep(LOOP_DELAY * 1000);
	   }

	   cleanup_platform();

	return 0;
}

/*--------------------------------------------------------------------------*/
/* function definition (private/not exported)                               */
/*--------------------------------------------------------------------------*/
static int get_button_data_BLOCKING(void)
{
	int button_data = 0;
	while(button_data == 0) button_data = XGpio_DiscreteRead(&input, 1);
	while(XGpio_DiscreteRead(&input, 1) != 0); // wait on button release
	return button_data;
}

static void print_help(void)
{
	xil_printf("Welcome in the demo app!\n\r");
	xil_printf("Use the BTNs to select the mode:\n\r");
	xil_printf("\tBTN0 -> SHA512 demo\n\r");
	xil_printf("\tBTN1 -> PUF demo\n\r");
	xil_printf("\tBTN2 -> AES demo\n\r");
	xil_printf("\tBTN3 -> RNG demo\n\r");
}

static void DEMO_CRO_puf_only(void)
{
	CRO_puf_t cro = {
			.core_addr = XPAR_CRO_PUF_0_S00_AXI_BASEADDR,
			.challenge = {0xBADC0FFE, 0xBADC0FFE, 0xBADC0FFE, 0xBADC0FFE},
			.control = {0x99999999, 0x99999999, 0x99999999},
			.ready = FALSE,
			.started = FALSE
	};

	CRO_raw_resp_t resp = {};

	xil_printf("\n\r======================== CRO puf ============================\n\r");
	xil_printf("Enter oscillator delay [ms]: ");
	uint32_t delay_ms = read_uint32();
	if(delay_ms < 5000)
	{
		delay_ms = 25000;
		printf("Input too low! Using 25s!\n");
	}

	CRO_write_inputs(&cro);
	CRO_start(&cro);
	usleep(delay_ms * 1000);
	CRO_stop(&cro, &resp);

	xil_printf("\n\r\t-> Response is 0x%08x --- DEBUG: 0x%08x - 0x%08x\n\r\n\r", resp.response, resp.top_out, resp.bot_out);
	xil_printf("Returning to main menu!\n\r\n\r");
	print_help();
}

static void DEMO_AES_only(void)
{
	uint32_t input_data[4] = {}, output_data[4] = {};
	bool reuse_previous_result = false;
	bool finish = false;

	xil_printf("\n\r======================== AES ============================\n\r");
	xil_printf("Select AES key length:\n\r"
				"\tBTN0 for 128bit\n\r"
				"\tBTN1 for 256bit\n\r");

	key_length_t keylen = get_button_data_BLOCKING() - 1;
	if(keylen >= AES_KEY_ERROR)
	{
		keylen = AES_128_BIT_KEY;
	}
	xil_printf("You selected %s\n\r", keylen == AES_128_BIT_KEY ? "128bit" : keylen == AES_256_BIT_KEY ? "256bit" : "...something wrong... using 128bit");

	xil_printf("\n\rEnter the key to encrypt (or press enter to use a default): ");

	size_t nb_blocks = (keylen == AES_128_BIT_KEY ? 4 : 8);

	uint32_t *key = calloc(nb_blocks, sizeof(uint32_t));
	if (key == NULL)
	{
		xil_printf("Allocation failure key!\n\r");
		return;
	}

	read_str((char*)key, nb_blocks * sizeof(uint32_t));
	for(size_t i = 0; i < nb_blocks; i++)
		key[i] = change_endianness(key[i]); // fix endianness issue because of the lazy cast -> (char*)key
	xil_printf("\n\rWriting key into AES core:\n\r");
	print_data_block(key, nb_blocks);

	aes_init_key(key, keylen);
	free(key);

	do {
		xil_printf("Select AES mode:\n\r\tBTN0 for deciphering\n\r\tBTN1 for enciphering\n\r\n\r");
		cipher_mode_t cipher_mode = get_button_data_BLOCKING() - 1;
		if(cipher_mode >= AES_CIPHER_ERROR)
		{
			cipher_mode = AES_DECIPHER;
		}

		if(reuse_previous_result == false)
		{
			xil_printf("Enter string to %s (bit-padding will be added): ", cipher_mode == AES_ENCIPHER ? "encipher" : "decipher");
			read_n_padded_chars((char*)input_data, 4 * sizeof(uint32_t));
			for(size_t i = 0; i < 4; i++)
				input_data[i] = change_endianness(input_data[i]); // fix endianness issue
		}
		xil_printf("\n\r%s following input string:\n\r", cipher_mode == AES_ENCIPHER ? "Enciphering" : "Deciphering");
		print_data_block(input_data, 4);

		aes(input_data, output_data, keylen, cipher_mode);
		uint32_t tmp[4] = {};
		for(size_t i = 0; i < 4; i++)
			tmp[i] = change_endianness(output_data[i]);
		xil_printf("Result is:\n\r");
		print_data_block(output_data, 4);

		if(cipher_mode == AES_DECIPHER)
			xil_printf("\n\rUnpadded string is %s\n\r", (const char *)tmp);

		xil_printf("Done!\n\r\tBTN0 to reuse the output as input\n\r\tBTN1 to select a new input data\n\r\t"
				"BTN2 or BTN4 to return to main menu\n\r\n\r");

		switch(get_button_data_BLOCKING())
		{
			case 0b0001:
				for(size_t i = 0; i < 4; i++)
					input_data[i] = output_data[i];
				reuse_previous_result = true;
				break;
			case 0b0010:
				reuse_previous_result = false;
				break;
			case 0b0100:
			case 0b1000:
			default:
				finish = true;
				break;
		}
	} while (finish == false);


	xil_printf("Returning to main menu!\n\r\n\r");
	print_help();
}

static void DEMO_RNG_only(void)
{
	xil_printf("\n\r======================== RNG ============================\n\r");
	xil_printf("Not implemented yet!\n\r");

	xil_printf("Returning to main menu!\n\r\n\r");
	print_help();
}

static void DEMO_SHA512_only(void)
{
	sha512_mode_t mode = MODE_SHA_512;
	size_t digest_len = 16;
	uint32_t first_block[32] = {};
	uint32_t digest[16] = {};
	int btn = 0;

	// blocking function
	xil_printf("\n\r======================== SHA-2 ============================\n\r");
	xil_printf("Select SHA-2 mode:\n\r"
			"\tBTN0 for SHA-2 512_224\n\r"
			"\tBTN1 for SHA-2 512_256\n\r"
			"\tBTN2 for SHA-2 384\n\r"
			"\tBTN3 for SHA-2 512\n\r\n\r");

	switch(get_button_data_BLOCKING())
	{
		case 0b0001:
			mode = MODE_SHA_512_224;
			digest_len = 7;
			xil_printf("=> Using SHA-2 512_224\n\r");
			break;
		case 0b0010:
			mode = MODE_SHA_512_256;
			digest_len = 8;
			xil_printf("=> Using SHA-2 512_256\n\r");
			break;
		case 0b0100:
			mode = MODE_SHA_384;
			digest_len = 12;
			xil_printf("=> Using SHA-2 384\n\r");
			break;
		case 0b1000:
			mode = MODE_SHA_512;
			digest_len = 16;
			xil_printf("=> Using SHA-2 512\n\r");
			break;
		default:
			xil_printf("=> Unknown input, using SHA-2 512\n\r");
			break;
	}

	xil_printf("Enter the string to hash: ");
	read_n_padded_chars((char*)first_block, 32 * sizeof(uint32_t));
	for(size_t i = 0; i < 32; i++)
		first_block[i] = change_endianness(first_block[i]); // fix endianness issue
	print_data_block(first_block, 32);
	xil_printf("\n\r");

	sha512_first_round(first_block, mode);

	memset(first_block, 0, sizeof(u32)*32);
	sha512_read_block(first_block);
	xil_printf("Reading back input value:\n\r");
	print_data_block(first_block, 32);

	memset(digest, 0, sizeof(u32)*digest_len);
	sha512_read_digest(digest);
	xil_printf("Result is:\n\r");
	print_data_block(digest, digest_len);

	do
	{
		xil_printf("\n\r---------------------------\n\rBTN0 to rehash\n\rBTN1 to add salt\n\rBTN2 ot BTN3 to return to main menu\n\r---------------------------\n\r");

		btn = get_button_data_BLOCKING();

		if(btn == 0b0001) // take digest, add padding and put it back into hash core. No idea if this actually makes sense....
		{
			memset(first_block, 0, sizeof(u32)*32);
			for(size_t i = 0; i < digest_len; i++)
			{
				first_block[i] = digest[i];
			}
			first_block[digest_len] = 0x80000000;
			first_block[31] = (digest_len * 32) / 2;

			sha512_first_round(first_block, mode);

			memset(first_block, 0, sizeof(u32)*32);
			sha512_read_block(first_block);
			xil_printf("Reading back input value:\n\r");
			print_data_block(first_block, 32);

			memset(digest, 0, sizeof(u32)*digest_len);
			sha512_read_digest(digest);
			xil_printf("Result is:\n\r");
			print_data_block(digest, digest_len);
		}
		else if(btn == 0b0010)
		{
			xil_printf("Enter salt string: ");
			read_n_padded_chars((char*)first_block, 32 * sizeof(uint32_t));
			for(size_t i = 0; i < 32; i++)
				first_block[i] = change_endianness(first_block[i]); // fix endianness issue
			xil_printf("\n\rHashing...\n\r");

			sha512_second_round(first_block);

			memset(first_block, 0, sizeof(u32)*32);
			sha512_read_block(first_block);
			xil_printf("Reading back input value:\n\r");
			print_data_block(first_block, 32);

			memset(digest, 0, sizeof(u32)*digest_len);
			sha512_read_digest(digest);
			xil_printf("Result is:\n\r");
			print_data_block(digest, digest_len);
		}

	} while (btn == 0b0010 || btn == 0b0001);

	xil_printf("Returning to main menu!\n\r\n\r");
	print_help();
}




