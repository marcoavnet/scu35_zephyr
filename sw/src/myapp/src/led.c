#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>
#include <zephyr/drivers/gpio.h>

/* Get LED from devicetree */
#define LED0_NODE DT_ALIAS(led0)

#if !DT_NODE_HAS_STATUS(LED0_NODE, okay)
#error "No LED0 alias found in device tree"
#endif

static const struct gpio_dt_spec led = GPIO_DT_SPEC_GET(LED0_NODE, gpios);



/* LED thread function */
void led_thread(void *arg1, void *arg2, void *arg3)
{
    if (!gpio_is_ready_dt(&led)) {
        printk("LED device not ready\n");
        return;
    }

    gpio_pin_configure_dt(&led, GPIO_OUTPUT_ACTIVE);

    while (1) {
        gpio_pin_toggle_dt(&led);
        k_sleep(K_MSEC(50));
    }
}
