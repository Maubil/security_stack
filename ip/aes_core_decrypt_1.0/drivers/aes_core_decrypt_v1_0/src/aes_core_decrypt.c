

/***************************** Include Files *******************************/
#include "aes_core_decrypt.h"
#include "xstatus.h"

#define EMPTY_ADDR  (0)

/************************** Function Definitions ***************************/

static u32 core_base_addr = EMPTY_ADDR;
static bool core_ready;

void aes_core_decrypt_set_addr(u32 base_addr)
{
    core_base_addr = base_addr;
}

XStatus aes_core_decrypt_init_key(const u32 key[4])
{
    if (core_base_addr == EMPTY_ADDR)
    {
        return XST_DEVICE_NOT_FOUND;
    }

    Xil_Out32(core_base_addr, 0x00000000); // reset
	Xil_Out32(core_base_addr, 0x00000001);

	for(size_t i=0; i < 4; i++)
	{
		Xil_Out32(base_ip_addr + 16 - i*4, key[i]);
	}

	Xil_Out32(core_base_addr, 0x00000005); // key load
	Xil_Out32(core_base_addr, 0x00000001);

    core_ready = true;

    return XST_SUCCESS;
}

XStatus aes_core_decrypt(const u32 ciphertext[4], u32 plaintext[4])
{
    if (base_addr == EMPTY_ADDR)
    {
        return XST_DEVICE_NOT_FOUND;
    }

    if (core_ready == false)
    {
        return XST_DEVICE_IS_STOPPED;
    }

    for(size_t i=0; i < 16; i++)
	{
        Xil_Out32(core_base_addr + 32 - i*4, ciphertext[i]);
	}

	Xil_Out32(core_base_addr, 0x00000003); // trigger
	Xil_Out32(core_base_addr, 0x00000001);

	for(size_t i=0; i < 16; i++)
	{
		plaintext[i] = Xil_In32(core_base_addr + 48 - i*4);
	}

    return XST_SUCCESS;
}
