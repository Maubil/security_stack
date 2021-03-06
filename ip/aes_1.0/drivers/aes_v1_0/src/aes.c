

/***************************** Include Files *******************************/
#include "xil_types.h"
#include "xil_io.h"
#include "xstatus.h"
#include "sleep.h"

#include "aes.h"

/************************** Function Definitions ***************************/
static u32 ip_core_addr = 0;

void aes_set_addr(u32 addr)
{
	ip_core_addr = addr;
}

XStatus aes_init_key(const u32 *key, const key_length_t key_length)
{
	if(ip_core_addr == 0)
	{
		xil_printf("No address!!\n");
		return XST_FAILURE;
	}

    if (key_length >= AES_KEY_ERROR)
    {
    	xil_printf("Key length error!!\n");
        return XST_FAILURE;
    }

    if (key == NULL)
    {
    	xil_printf("NULL pointer!!\n");
        return XST_FAILURE;
    }

	Xil_Out32(ip_core_addr + 8, key[key_length == AES_128_BIT_KEY ? 3 : 7]);
	Xil_Out32(ip_core_addr + 12, key[key_length == AES_128_BIT_KEY ? 2 : 6]);
	Xil_Out32(ip_core_addr + 16, key[key_length == AES_128_BIT_KEY ? 1 : 5]);
	Xil_Out32(ip_core_addr + 20, key[key_length == AES_128_BIT_KEY ? 0 : 4]);

    if(key_length == AES_256_BIT_KEY)
    {
        Xil_Out32(ip_core_addr + 24, key[3]);
        Xil_Out32(ip_core_addr + 28, key[2]);
        Xil_Out32(ip_core_addr + 32, key[1]);
        Xil_Out32(ip_core_addr + 36, key[0]);
    }

	Xil_Out32(ip_core_addr + 4, (key_length << 1)); // set key length
	Xil_Out32(ip_core_addr + 0, 0x00000001); // init key expansion
	usleep(1);
	// two clock cycles are needed at least at this point
	Xil_Out32(ip_core_addr + 0, 0x00000000);
	// key expansion done
	usleep(1);

	return XST_SUCCESS;
}

XStatus aes(const u32 input_data[4], u32 result[4], key_length_t key_length, cipher_mode_t encdec)
{
	if(ip_core_addr == 0)
	{
		xil_printf("No address!!\n");
		return XST_FAILURE;
	}

    if (key_length >= AES_KEY_ERROR)
    {
    	xil_printf("Key length error!!\n");
        return XST_FAILURE;
    }

    if (input_data == NULL || result == NULL)
    {
    	xil_printf("NULL pointer!!\n");
        return XST_FAILURE;
    }

    if (encdec >= AES_CIPHER_ERROR)
    {
    	xil_printf("Unknown cipher mode!!\n");
        return XST_FAILURE;
    }

	Xil_Out32(ip_core_addr + 4, (key_length << 1) | (encdec)); // key expansion should be done for now
	// write key length and encdec modus

	// write out plaintext to core
	Xil_Out32(ip_core_addr + 40, input_data[3]);
	Xil_Out32(ip_core_addr + 44, input_data[2]);
	Xil_Out32(ip_core_addr + 48, input_data[1]);
	Xil_Out32(ip_core_addr + 52, input_data[0]);

    // start computation
    Xil_Out32(ip_core_addr + 0x0, 0x2); // set next
    usleep(1);
	Xil_Out32(ip_core_addr + 0x0, 0); // reset next

    usleep(1);

    // get result
	result[3] = Xil_In32(ip_core_addr + 56);
	result[2] = Xil_In32(ip_core_addr + 60);
	result[1] = Xil_In32(ip_core_addr + 64);
	result[0] = Xil_In32(ip_core_addr + 68);

	return XST_SUCCESS;
}
