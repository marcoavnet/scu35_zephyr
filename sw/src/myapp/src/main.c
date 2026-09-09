#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>


#include "led.h"

/* Thread stack */
#define STACK_SIZE 4096
#define PRIORITY 5

K_THREAD_STACK_DEFINE(led_stack, STACK_SIZE);
struct k_thread led_thread_data;



int main(void)
{
    uint32_t loops = 0;
    printk("Hello from my own Zephyr app on MicroBlaze V!\n");

    /* Create LED thread */
    k_thread_create(&led_thread_data, led_stack,
                    STACK_SIZE,
                    led_thread,
                    NULL, NULL, NULL,
                    PRIORITY, 0, K_NO_WAIT);

    while (1) {
        printk("Uptime: %lld ms\n", k_uptime_get());
        k_sleep(K_SECONDS(1));
        loops++;
    }

    return 0;
}
