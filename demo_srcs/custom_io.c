/*
 * custom_io.c
 *
 *  Created on: Jan 16, 2019
 *      Author: vm
 */


#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

#include "xil_io.h"

#include "custom_io.h"


static bool is_ascii_an_int(char byte);
static bool is_ascii_a_hex(char byte);

/* credit goes to wikipedia https://en.wikipedia.org/wiki/Endianness */
uint32_t change_endianness(uint32_t value)
{
    return    ((value & 0x000000FF) << 24)
    		| ((value & 0x0000FF00) << 8)
			| ((value & 0x00FF0000) >> 8)
			| ((value & 0xFF000000) >> 24);
}

void read_n_padded_chars(char *output, size_t len)
{
	size_t read_len = read_str(output, len);

	if (read_len < (len - 1))
	{
		output[read_len] = 0x80;	// pad with a 1 bit after the end of the string
	}

	if (read_len < (len - 1))
	{
		uint16_t padding_size = read_len * 8; // nb bytes * 8 => results in bits
		output[len - 2] = (char)(padding_size >> 8);
		output[len - 1] = (char)(padding_size & 0xFF);
	}
}

void print_data_block(u32 *data, size_t len)
{
	u32 *tmp = data;
	xil_printf("\t0x");
	for (size_t i = 0; i < len; i++)
	{
		if(i%16 == 0 && i != 0)
			xil_printf("\n\r\t  ");

		xil_printf("%08x", *tmp);

		if(i%2 == 1)
			xil_printf("   ");

		tmp++;
	}
	xil_printf("\n\r\n\r");
}

/* read byte per byte from input buffer and write to buf until
 * reaching nbytes or an EOL character is received */
size_t read_str(char *buf, size_t nbytes)
{
	size_t numbytes = 0;

	if(buf != NULL)
	{
		for (size_t i = 0; i < nbytes; i++)
		{
			*(buf + i) = inbyte();
			if ((*(buf + i) == '\n' )|| (*(buf + i) == '\r'))
			{
				break;
			}
			numbytes++;
			outbyte(*(buf + i)); // show the values entered
		}
	}

	outbyte('\n');
	outbyte('\r');
	return numbytes;
}

static bool is_ascii_an_int(char byte)
{
	if(byte >= '0' && byte <= '9')
	{
		return true;
	}
	return false;
}

static bool is_ascii_a_hex(char byte)
{
	if(byte >= 'a' && byte <= 'f')
	{
		return true;
	}
	return is_ascii_an_int(byte);
}

size_t read_hex(uint8_t *buf, size_t nbytes)
{
	size_t numbytes = 0;

	if(buf != NULL)
	{
		for (size_t i = 0; i < nbytes * 2; i++)
		{
			char8 input_byte = 0;

			do {
				input_byte = tolower(inbyte());
			} while (is_ascii_a_hex(input_byte) != true && input_byte != '\n' && input_byte != '\r');

			if (input_byte >= '0' && input_byte <= '9')
			{
				input_byte -= 48;
			}
			else if(input_byte >= 'a' && input_byte <= 'f')
			{
				input_byte -= 65;
			}
			else { // CR or LF
				break;
			}

			uint32_t index = 0;
			if (i != 0 && i != 1)
			{
				index = i/2;
			}
			if (i % 2 == 0)
			{
				*(buf + index) = (input_byte << 4) & 0xF0;
			}
			else
			{
				*(buf + index) |= input_byte & 0x0F;
			}

			numbytes++;
			outbyte(input_byte); // show the values entered
		}
	}

	outbyte('\n');
	outbyte('\r');
	return numbytes;
}

uint32_t read_uint32(void)
{
	char int_buf[10 + 1] = {};

	for (size_t i = 0; i < 10; i++)
	{
		char8 input_byte = 0;

		do {
			input_byte = inbyte();
		} while (is_ascii_an_int(input_byte) != true && input_byte != '\n' &&  input_byte != '\r');

		if (input_byte >= '0' && input_byte <= '9') // 0-9
		{
			int_buf[i] = input_byte;
		}
		else { // CR or LF
			break;
		}
		outbyte(input_byte); // show the values entered
	}

	outbyte('\n');
	outbyte('\r');
	return atoi(int_buf);
}
