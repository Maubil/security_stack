/*
 * custom_io.h
 *
 *  Created on: Jan 16, 2019
 *      Author: vm
 */

#ifndef SRC_CUSTOM_IO_H_
#define SRC_CUSTOM_IO_H_

#define MAX_STRING_LEN (128)

uint32_t change_endianness(uint32_t value);
void read_n_padded_chars(char *output, size_t len);
void print_data_block(u32 *data, size_t len);
size_t read_str(char *buf, size_t nbytes);
size_t read_hex(uint8_t *buf, size_t nbytes);
uint32_t read_uint32(void);

#endif /* SRC_CUSTOM_IO_H_ */
