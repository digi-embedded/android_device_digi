/*
 * Copyright 2019, Digi International Inc.
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
package com.digi.android.server;

import android.app.Application;

import android.os.ServiceManager;
import com.android.server.gpio.GPIOServiceImpl;
import com.android.server.gpio.IGPIOService;
import com.android.server.i2c.I2CServiceImpl;
import com.android.server.i2c.II2CService;
import com.android.server.spi.SPIServiceImpl;
import com.android.server.spi.ISPIService;

public class DigiServicesApp extends Application {

    static {
        System.loadLibrary("digiservices");
    }

    @Override
    public void onCreate() {
        super.onCreate();

        ServiceManager.addService(IGPIOService.class.getName(),
                                  new GPIOServiceImpl(this));

        ServiceManager.addService(II2CService.class.getName(),
                                  new I2CServiceImpl(this));

        ServiceManager.addService(ISPIService.class.getName(),
                                  new SPIServiceImpl(this));
    }

    @Override
    public void onTerminate() {
        super.onTerminate();
    }
}
