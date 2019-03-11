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
package com.digi.android.server.location;

import android.location.Criteria;
import android.os.Bundle;
import android.os.SystemClock;
import android.os.WorkSource;
import android.util.Log;

import com.android.location.provider.LocationProviderBase;
import com.android.location.provider.LocationRequestUnbundled;
import com.android.location.provider.ProviderPropertiesUnbundled;
import com.android.location.provider.ProviderRequestUnbundled;

import static android.location.LocationProvider.AVAILABLE;

/**
 * Location provider to supply the location (latitude, longitude, altitude) of
 * the device.
 *
 * <p>This location is based on the values of some system properties. These
 * properties establish the initial location and the behavior of the provider
 * as 'static' or 'random'. See {@link LocationThread}</p>
 *
 * @see LocationThread
 */
public class DigiLocationProvider extends LocationProviderBase {
    // Constants.
    private static final String TAG = "DigiLocationProvider";
    private static final long MIN_REFRESH_INTERVAL = 2500; // milliseconds
    private static final ProviderPropertiesUnbundled PROPS = ProviderPropertiesUnbundled.create(
            false, // requiresNetwork
            false, // requiresSatellite
            false, // requiresCell
            false, // hasMonetaryCost
            true,  // supportsAltitude
            false, // supportsSpeed
            false, // supportsBearing
            Criteria.POWER_LOW, // powerRequirement
            Criteria.ACCURACY_COARSE); // accuracy

    // Variables
    private final LocationThread lThread;

    public DigiLocationProvider() {
        super(TAG, PROPS);
        this.lThread = new LocationThread(this);
    }

    @Override
    public void onEnable() {
        Log.d(TAG, "onEnable");
    }

    @Override
    public void onDisable() {
        Log.d(TAG, "onDisable");
        lThread.stop();
    }

    @Override
    public void onSetRequest(ProviderRequestUnbundled request, WorkSource source) {
        Log.v(TAG, "onSetRequest: " + request + " by " + source);
        
        boolean autoUpdate = request.getReportLocation();
        long autoTime = Long.MAX_VALUE;
        for (final LocationRequestUnbundled r : request.getLocationRequests()) {
            Log.d(TAG, "onSetRequest: request=" + r);
            if (autoTime > r.getInterval())
                autoTime = r.getInterval();
            autoUpdate = true;
        }

        autoTime = Math.max(autoTime, MIN_REFRESH_INTERVAL);
        Log.v(TAG, "using autoUpdate=" + autoUpdate + " autoTime=" + autoTime);
        if (autoUpdate) {
            lThread.setReportInterval(autoTime);
            lThread.start();
        } else {
            lThread.stop();
        }
    }

    @Override
    public int onGetStatus(Bundle extras) {
        return AVAILABLE;
    }

    @Override
    public long onGetStatusUpdateTime() {
        return SystemClock.elapsedRealtime();
    }

    /**
     * Destroys this location provider.
     */
    public void destroy() {
        lThread.stop();
    }
}
