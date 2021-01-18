/*
 * main.c
 *
 *  Created on: 2021年1月18日
 *      Author: Thirty14
 */


#include <stdio.h>
#include "./gpio_conf.h"

#define EMIO_LED	54

int pin_set(struct gpio_mio_confaddr pin, int status);

int main(int argc, char *argv[])
{
	struct gpio_mio_confaddr emio_led;

	pin_checkout_maskaddr(EMIO_LED, &emio_led.data_mask_lsw, &emio_led.data_mask_msw);
	pin_checkout_dataaddr(EMIO_LED, &emio_led.data, &emio_led.data_ro);
	pin_checkout_oconaddr(EMIO_LED, &emio_led.dirm, &emio_led.oen);
	pin_checkout_bankinfo(EMIO_LED, &emio_led.inbank, &emio_led.banknum);
	printf("pin EMIO_LED mask: lsw=0x%x, msw=0x%x \r\n", emio_led.data_mask_lsw, emio_led.data_mask_msw);
	printf("pin EMIO_LED data: 0x%x, data_ro:0x%x \r\n", emio_led.data, emio_led.data_ro);
	printf("pin EMIO_LED output config register: dirm=0x%x, oen=0x%x \r\n", emio_led.dirm, emio_led.oen);
	printf("pin EMIO_LED output bankinfo : in bank_%d, bank_num_%d \r\n", emio_led.inbank, emio_led.banknum);

	pin_maskset(EMIO_LED, emio_led.data_mask_lsw, emio_led.data_mask_msw);
	pin_oconset(EMIO_LED, emio_led.dirm, emio_led.oen, mode_o);

	pin_maskset(EMIO_LED, emio_led.data_mask_lsw, emio_led.data_mask_msw);
	pin_oconset(EMIO_LED, emio_led.dirm, emio_led.oen, mode_o);
	pin_set(emio_led, 1);


	return 0;
}

int pin_set(struct gpio_mio_confaddr pin, int status)
{
	switch(status) {
	case 0:
		*(unsigned int *)pin.data &= ~(1 << pin.banknum);
		break;
	case 1:
		*(unsigned int *)pin.data |= ~(1 << pin.banknum);
		break;
	}
	return (*(unsigned int *)pin.data_ro & (1 << pin.banknum));
}


/*
#include <stdio.h>
#include "./gpio_conf.h"
#include <sleep.h>

#define M10	10
#define M16	16

int pin_set(struct gpio_mio_confaddr pin, int status);

int main(int argc, char *argv[])
{
	struct gpio_mio_confaddr m10;
	int i, delay;

	pin_checkout_maskaddr(M10, &m10.data_mask_lsw, &m10.data_mask_msw);
	pin_checkout_dataaddr(M10, &m10.data, &m10.data_ro);
	pin_checkout_oconaddr(M10, &m10.dirm, &m10.oen);
	pin_checkout_bankinfo(M10, &m10.inbank, &m10.banknum);
	printf("pin M10 mask: lsw=0x%x, msw=0x%x \r\n", m10.data_mask_lsw, m10.data_mask_msw);
	printf("pin M10 data: 0x%x, data_ro:0x%x \r\n", m10.data, m10.data_ro);
	printf("pin M10 output config register: dirm=0x%x, oen=0x%x \r\n", m10.dirm, m10.oen);
	printf("pin M10 output bankinfo : in bank_%d, bank_num_%d \r\n", m10.inbank, m10.banknum);

	pin_maskset(M10, m10.data_mask_lsw, m10.data_mask_msw);
	pin_oconset(M10, m10.dirm, m10.oen, mode_o);

	while(1) {
		pin_maskset(M10, m10.data_mask_lsw, m10.data_mask_msw);
		pin_oconset(M10, m10.dirm, m10.oen, mode_o);
		i = pin_set(m10, 1);
		// *(unsigned int *)m10.data_mask_lsw &= ~(1 << 10);
		// 向lsw低16位写入数据没有用
		printf("Pin M10 status: %d, data_lsw[15:0]: 0x%lx \r\n", i, *m10.data_mask_lsw);
		sleep(1);
		//for (delay = 0; delay < 100000000; delay++);

		pin_maskset(M10, m10.data_mask_lsw, m10.data_mask_msw);
		pin_oconset(M10, m10.dirm, m10.oen, mode_o);
		i = pin_set(m10, 0);
		//*(unsigned int *)m10.data_mask_lsw |= ~(1 << 10);
		printf("Pin M10 status: %d, data_lsw[15:0]: 0x%lx \r\n", i, *m10.data_mask_lsw);
		sleep(1);
		//for (delay = 0; delay < 100000000; delay++);
	}

	return 0;
}

int pin_set(struct gpio_mio_confaddr pin, int status)
{
	switch(status) {
	case 0:
		*(unsigned int *)pin.data &= ~(1 << pin.banknum);
		break;
	case 1:
		*(unsigned int *)pin.data |= ~(1 << pin.banknum);
		break;
	}
	return (*(unsigned int *)pin.data_ro & (1 << pin.banknum));
}
*/
