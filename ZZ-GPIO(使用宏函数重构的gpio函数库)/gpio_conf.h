/*
 * gpio_mio.h
 *
 *  Created on: 2021Äê1ÔÂ16ÈÕ
 *      Author: Thirty14
 */

#ifndef SRC_GPIO_MIO_H_
#define SRC_GPIO_MIO_H_

#define GPIO_BASEADDR	0xE000A000
#define GPIO_HIGHADDR	0xE000AFFF

// None Interrupt
#define GPIO_DATA_MASK_LSW_OFFSET	0x00000000
#define GPIO_DATA_MASK_MSW_OFFSET	0x00000004
#define GPIO_DATA_OFFSET	0x00000040
#define GPIO_DATA_RO		0x00000060
#define GPIO_DIRM_OFFSET	0x00000204
#define GPIO_OUTEN_OFFSET	0x00000208



struct gpio_mio_confaddr{
	unsigned int *data_mask_lsw;
	unsigned int *data_mask_msw;
	unsigned int *data;
	unsigned int *data_ro;
	unsigned int *dirm;
	unsigned int *oen;
	unsigned int inbank;
	unsigned int banknum;
};

#define bank_0	0
#define bank_1	1
#define bank_2	2
#define bank_3	3

#define mode_i	0
#define mode_o	1

//#define pin_checkout_bank(pin_num)	(pin_num > 31 ? 1 : 0)
#define pin_checkout_bank(pin_num)	\
({	\
	int bank;	\
	if(pin_num < 54)	\
		if(pin_num < 32)	\
			bank = 0;	\
		else	\
			bank = 1;	\
	else	\
		if(pin_num < 86)	\
			bank = 2;	\
		else	\
			bank = 3;	\
	bank;	\
})	\

#define pin_num_inbank(pin_num, num_inbank)	{	\
	if(pin_num < 32)	num_inbank = pin_num;	\
	else if(pin_num < 54)	num_inbank = pin_num - 32;	\
	else if(pin_num < 86)	num_inbank = pin_num - 54;	\
	else	num_inbank = pin_num - 86;	\
}

#define pin_checkout_maskaddr(pin_num, lsw, msw)	{	\
	switch(pin_checkout_bank(pin_num)) {	\
	case bank_0:	\
		*(unsigned int *)lsw = GPIO_BASEADDR + 0x00000000;	\
		*(unsigned int *)msw = GPIO_BASEADDR + 0x00000004;	\
		break;	\
	case bank_1:	\
		*(unsigned int *)lsw = GPIO_BASEADDR + 0x00000008;	\
		*(unsigned int *)msw = GPIO_BASEADDR + 0x0000000c;	\
		break;	\
	case bank_2:	\
		*(unsigned int *)lsw = GPIO_BASEADDR + 0x00000010;	\
		*(unsigned int *)msw = GPIO_BASEADDR + 0x00000014;	\
		break;	\
	case bank_3:	\
		*(unsigned int *)lsw = GPIO_BASEADDR + 0x00000018;	\
		*(unsigned int *)msw = GPIO_BASEADDR + 0x0000001c;	\
		break;	\
	}	\
}
#define pin_maskset(pin_num, lsw, msw)	{	\
	int pin_banknum;	\
	pin_num_inbank(pin_num, pin_banknum);	\
	if(pin_banknum < 16)	*(unsigned int *)lsw = ~((1 << pin_banknum) << 16);	\
	else	*(unsigned int *)msw = ~((1 << (pin_banknum - 16)) << 16);	\
}

#define pin_checkout_dataaddr(pin_num, data, data_ro)	{	\
	*(unsigned int *)data = GPIO_BASEADDR + 0x00000040 + pin_checkout_bank(pin_num) * 0x04;	\
	*(unsigned int *)data_ro = GPIO_BASEADDR + 0x00000060 + pin_checkout_bank(pin_num) * 0x04;	\
}

#define pin_checkout_oconaddr(pin_num, dirm, oen)	{	\
	*(unsigned int *)dirm = GPIO_BASEADDR + pin_checkout_bank(pin_num) * 0x40 + 0x00000204;	\
	*(unsigned int *)oen = GPIO_BASEADDR + pin_checkout_bank(pin_num) * 0x40 + 0x00000208;	\
}
#define pin_oconset(pin_num, dirm, oen, mod)	{	\
	int pin_banknum;	\
	pin_num_inbank(pin_num, pin_banknum);	\
	if(mod == mode_o)	{	\
		*(unsigned int *)dirm |= (1 << pin_banknum);	\
		*(unsigned int *)oen |= (1 << pin_banknum);		\
	}	\
	else {	\
		*(unsigned int *)dirm &= ~(1 << pin_banknum);	\
		*(unsigned int *)oen &= ~(1 << pin_banknum);	\
	}	\
}	// MIO_7 and MIO_8 con not be set into input mode

#define pin_checkout_bankinfo(pin_num, inbank, banknum)	{	\
	*(unsigned int *)inbank = pin_checkout_bank(pin_num);	\
	pin_num_inbank(pin_num, *(unsigned int *)banknum);	\
}

#endif /* SRC_GPIO_MIO_H_ */
