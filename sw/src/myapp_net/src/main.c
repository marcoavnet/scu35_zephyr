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

#include "led.h"
#include "websrv.h"

/* Thread stack */
#define STACK_SIZE 1024
#define PRIORITY 5

K_THREAD_STACK_DEFINE(led_stack, STACK_SIZE);
K_THREAD_STACK_DEFINE(websrv_stack, STACK_SIZE);


struct k_thread led_thread_data;
struct k_thread websrv_thread_data;



int main(void)
{
    printk("Hello from my own Zephyr app on MicroBlaze V!\n");
    printk("Built: " __DATE__ " "__TIME__ "\n");

    init_leds();

    /* Create LED thread */
    k_thread_create(&led_thread_data, led_stack,
                    STACK_SIZE,
                    led_thread,
                    NULL, NULL, NULL,
                    PRIORITY, 0, K_NO_WAIT);

    k_thread_name_set(&led_thread_data, "led");

/*
    k_thread_create(&websrv_thread_data, websrv_stack,
                    STACK_SIZE,
                    websrv_thread,
                    NULL, NULL, NULL,
                    PRIORITY, 0, K_NO_WAIT);

    k_thread_name_set(&led_thread_data, "websrv");
*/
    return 0;
}
