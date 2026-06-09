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

#ifndef LED_H
#define LED_H

void init_leds(void);
void led_thread(void *arg1, void *arg2, void *arg3);
void led1_off(void);
void led1_on(void);

#endif
