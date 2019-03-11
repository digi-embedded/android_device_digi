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

import android.annotation.TargetApi;
import android.location.Location;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.os.SystemClock;
import android.os.SystemProperties;
import android.util.Log;

import com.android.location.provider.LocationProviderBase;

import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.Random;

/**
 * This class reports the location to the location provider by reading the
 * several system properties:
 *
 * <ul>
 * <li>{@code digi.location.default} establishes the default values of latitude,
 * longitude, and altitude to be reported following the format
 * {@code latitude,longitude,altitude}. If not defined or invalid values
 * {@code 42.46288,-2.43798,350}.</li>
 * <li>{@code digi.location.mode.random} sets the location behavior. When it is
 * {@code false} the configured static location is always reported. If it is
 * {@code true} a a random location is calculated based on the first configured.
 * This random value is located inside a 500m radius circle surrounding the
 * last reported location. If it is not defined its value is {@code false}.</li>
 * </ul>
 *
 * @see DigiLocationProvider
 */
public class LocationThread implements Runnable {
    // Constants.
    private static final String TAG = "LocationThread";
    private static final String LOC_DEF_PROPERTY = "digi.location.default";
    private static final String LOC_RANDOM_PROPERTY = "digi.location.mode.random";
    private static final String RANDOM = "random";
    private static final String STATIC = "static";
    private static final String ERROR_PROP_LOC = "Error getting Digi property location. Using default location (error: %s)";
    private static final double DEF_LATITUDE = 42.46288;
    private static final double DEF_LONGITUDE = -2.43798;
    private static final double DEF_ALTITUDE = 350;

    // Variables.
    private final DigiLocationProvider locationProvider;
    private boolean randomMode = false;
    private long reportInterval;
    private Location lastLocation, initLocation;
    private ScheduledThreadPoolExecutor executor;

    private final Random random = new Random();

    public LocationThread(DigiLocationProvider locationProvider) {
        this.locationProvider = locationProvider;
        initLocation = getLocationFromProperties();
    }

    @Override
    public void run() {
        Location location = null;
        Location propLoc = getLocationFromProperties();

        if (randomMode) {
            if (areLocationsEqual(initLocation, propLoc)) {
                location = getRandomLocation(lastLocation, 500);
            } else {
                location = propLoc;
                initLocation = propLoc;
            }
        } else {
            location = propLoc;
        }

        Log.d(TAG, "Just reported: " + location);
        report(location);
    }

    /**
     * Starts this location thread.
     */
    public void start() {
        if (executor != null) {
            executor.shutdownNow();
            executor = null;
        }
        executor = new ScheduledThreadPoolExecutor(1);
        if (randomMode)
            executor.scheduleAtFixedRate(this, 0, reportInterval, TimeUnit.MILLISECONDS);
        else
            executor.schedule(this, 0, TimeUnit.MILLISECONDS);
    }

    /**
     * Stops this location thread.
     */
    public void stop() {
        if (executor != null) {
            executor.shutdownNow();
            executor = null;
        }
    }

    /**
     * Configures the location report interval in milliseconds.
     *
     * @param interval number of milliseconds between location reports.
     */
    public void setReportInterval(long interval) {
        reportInterval = interval;
    }

    /**
     * Reads the location from system properties.
     *
     * @returns The location read from system properties or a default one if it
     *          is not configured or it is invalid.
     */
    private Location getLocationFromProperties() {
        double lat = DEF_LATITUDE, longi = DEF_LONGITUDE, alt = DEF_ALTITUDE;
        boolean useDefault = false;
        randomMode = SystemProperties.getBoolean(LOC_RANDOM_PROPERTY, false);

        String locString = SystemProperties.get(LOC_DEF_PROPERTY);
        String[] items = locString.split(",");
        if (items.length >= 3) {
            try {
                lat = Double.parseDouble(items[0].trim());
                longi = Double.parseDouble(items[1].trim());
                alt = Double.parseDouble(items[2].trim());
            } catch (NumberFormatException e) {
                useDefault = true;
                Log.d(TAG, String.format(ERROR_PROP_LOC, e.getMessage()));
            }
        } else {
            useDefault = true;
            Log.d(TAG, String.format(ERROR_PROP_LOC, "Invalid '" + LOC_DEF_PROPERTY + "' value"));
        }

        if (useDefault) {
            lat = DEF_LATITUDE;
            longi = DEF_LONGITUDE;
            alt = DEF_ALTITUDE;
        }

        return createLocation(randomMode ? RANDOM : STATIC, lat, longi, alt);
    }

    /**
     * Creates a new location to report.
     *
     * @param source name of the provider that generated this location.
     * @param latitude latitude in degrees.
     * @param longitude longitude in degrees.
     * @param altitude altitude, in meters above the WGS 84 reference ellipsoid.
     *
     * @return The created location.
     */
    private Location createLocation(String source, double latitude, double longitude, double altitude) {
        Location l = new Location(source);
        l.setTime(System.currentTimeMillis());
        l.setLatitude(latitude);
        l.setLongitude(longitude);
        l.setAltitude(altitude);
        return l;
    }

    /**
     * Returns {@code true} if the latitude, longitude, and altitude of the
     * provided locations are equal.
     *
     * @return {@code true} if the latitude, longitude, and altitude valeus of
     *         the locations are equal, {@code false} otherwise.
     */
    private boolean areLocationsEqual(Location l1, Location l2) {
        if (l1 == null && l2 == null)
            return true;
        if ((l1 == null && l2 != null) || (l1 != null && l2 == null))
            return false;
        if (l1.getLatitude() != l2.getLatitude())
            return false;
        if (l1.getLongitude() != l2.getLongitude())
            return false;
        return l1.getAltitude() == l2.getAltitude();
    }

    /**
     * Randomly generates a location nearby.
     *
     * @param currentLocation The current location used to generate the random
     *                        one.
     * @param radius The circle radius (in meters) surrounding the current
     *               location inside which the new random location will be
     *               inside.
     *
     * @return A new random location.
     */
    private Location getRandomLocation(Location currentLocation, double radius) {
        double x0 = currentLocation.getLongitude();
        double y0 = currentLocation.getLatitude();

        // Convert radius from meters to degrees.
        double radiusInDegrees = radius / 111320f;

        // Get a random distance and a random angle.
        double u = random.nextDouble();
        double v = random.nextDouble();
        double w = radiusInDegrees * Math.sqrt(u);
        double t = 2 * Math.PI * v;
        // Get the x and y delta values.
        double x = w * Math.cos(t);
        double y1 = w * Math.sin(t);

        // Compensate the x value.
        double x1 = x / Math.cos(Math.toRadians(y0));

        return createLocation(RANDOM, y0 + y1, x0 + x1, currentLocation.getAltitude());
    }

    /**
     * Reports the given location to the location provider.
     *
     * @param location The location to report.
     */
    private void report(Location location) {
        if (location == null ||
                (lastLocation != null && location.getTime() > 0 && location.getTime() <= lastLocation.getTime()))
            return;

        setLastLocation(location);

        locationProvider.reportLocation(location);
        Log.v(TAG, "location=" + location);
    }

    /**
     * Stores the last provided location.
     *
     * @param location The new last location.
     */
    private void setLastLocation(Location location) {
        if (location == null)
            return;

        location.setProvider(LocationManager.NETWORK_PROVIDER);

        if (location.getExtras() == null)
            location.setExtras(new Bundle());

        if (!location.hasAccuracy())
            location.setAccuracy(50000);

        if (location.getTime() <= 0)
            location.setTime(System.currentTimeMillis());

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1)
            updateElapsedRealtimeNanos(location);

        Location noGpsLocation = new Location(location);
        noGpsLocation.setExtras(null);
        location.getExtras().putParcelable(LocationProviderBase.EXTRA_NO_GPS_LOCATION, noGpsLocation);
        lastLocation = location;
    }

    /**
     * Updates the time of the given location, in elapsed real-time since system
     * boot.
     *
     * @param location The location to update.
     */
    @TargetApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    private void updateElapsedRealtimeNanos(Location location) {
        if (location.getElapsedRealtimeNanos() <= 0) {
            location.setElapsedRealtimeNanos(SystemClock.elapsedRealtimeNanos());
        }
    }
}
