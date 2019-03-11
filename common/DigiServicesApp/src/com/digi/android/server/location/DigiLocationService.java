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

import android.app.IntentService;
import android.content.Intent;
import android.os.IBinder;

/**
 * Location service to supply the location (latitude, longitude, altitude) of
 * the device.
 *
 * @see DigiLocationProvider
 */
public class DigiLocationService extends IntentService {
    // Constants.
    private static final String TAG = "DigiLocationService";

    // Variables.
    private static DigiLocationProvider provider;

    /**
     * Creates a LocationService.
     *
     * @param tag Used for debugging.
     */
    public DigiLocationService() {
        super(TAG);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return getProvider().getBinder();
    }

    @Override
    public boolean onUnbind(Intent intent) {
        DigiLocationProvider provider = getProvider();
        if (provider != null) {
            provider.onDisable();
        }
        destroyProvider();
        return super.onUnbind(intent);
    }

    @Override
    protected void onHandleIntent(Intent intent) {
        // Default implementation is to do nothing.
    }

    /**
     * Creates a new {@link DigiLocationProvider} or return the existing one.
     *
     * <p>This might be called more than once, the implementation has to ensure
     * that only one {@link DigiLocationProvider} is returned.</p>
     *
     * @return a new or existing {@link DigiLocationProvider} instance
     *
     * @see DigiLocationProvider
     */
    private synchronized DigiLocationProvider getProvider() {
        if (provider == null) {
            provider = new DigiLocationProvider();
        }
        return provider;
    }

    /**
     * Destroys the active {@link DigiLocationProvider}.
     *
     * <p>After this has been called, the {@link DigiLocationProvider} instance,
     * that was active before should no longer be returned with
     * {@link #getProvider()}.<p/>
     */
    protected void destroyProvider() {
        provider.destroy();
        provider = null;
    }
}
