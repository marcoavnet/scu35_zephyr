/******************************************************************************
 * Copyright (c) 2026 Marco Höfle, Avnet-Silica
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files to deal in the software
 * without restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
 ******************************************************************************/

#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>
#include <zephyr/drivers/gpio.h>

/* Get LED from devicetree */
#define LED0_NODE DT_ALIAS(led0)
#define LED1_NODE DT_ALIAS(led1)


#if !DT_NODE_HAS_STATUS(LED0_NODE, okay)
#error "No LED0 alias found in device tree"
#endif

#if !DT_NODE_HAS_STATUS(LED1_NODE, okay)
#error "No LED1 alias found in device tree"
#endif

static const struct gpio_dt_spec led0 = GPIO_DT_SPEC_GET(LED0_NODE, gpios);
static const struct gpio_dt_spec led1 = GPIO_DT_SPEC_GET(LED1_NODE, gpios);



/* LED thread function */
void led_thread(void *arg1, void *arg2, void *arg3)
{


    while (1) {
        gpio_pin_toggle_dt(&led0);
        k_sleep(K_MSEC(50));
    }
}


void led1_on(void)
{
    gpio_pin_set_dt(&led1, 1);
}

void led1_off(void)
{
    gpio_pin_set_dt(&led1, 0);
}

void init_leds(void)
{
    if (!gpio_is_ready_dt(&led0)) {
        printk("LED device not ready\n");
        return;
    }
    gpio_pin_configure_dt(&led0, GPIO_OUTPUT);

    if (!gpio_is_ready_dt(&led1)) {
        printk("LED device not ready\n");
        return;
    }
    gpio_pin_configure_dt(&led1, GPIO_OUTPUT);
}
