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
#include <zephyr/shell/shell.h>

#include "led.h"

static int cmd_led_on(const struct shell *sh, size_t argc, char **argv)
{
    shell_print(sh, "LED on");
    led1_on();
    return 0;
}

static int cmd_led_off(const struct shell *sh, size_t argc, char **argv)
{
    shell_print(sh, "LED off");
    led1_off();
    return 0;
}

SHELL_STATIC_SUBCMD_SET_CREATE(led_cmds,
    SHELL_CMD(on, NULL, "Switch LED on", cmd_led_on),
    SHELL_CMD(off, NULL, "Switch LED off", cmd_led_off),
    SHELL_SUBCMD_SET_END
);


SHELL_CMD_REGISTER(led, &led_cmds, "LED commands", NULL);
