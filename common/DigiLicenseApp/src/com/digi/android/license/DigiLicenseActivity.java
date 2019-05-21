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
package com.digi.android.license;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Window;
import android.webkit.CookieSyncManager;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.widget.Toast;

import java.io.File;

public class DigiLicenseActivity extends Activity {

    // Constants.
    private static final String TAG = "DigiLicenseActivity";

    private static final String LICENSE_LOCATION = "/vendor/etc/license.html";

    // Variables.
    private WebView mWebView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        CookieSyncManager.createInstance(this);

        requestWindowFeature(Window.FEATURE_PROGRESS);

        mWebView = new WebView(this);
        setContentView(mWebView);
        
        // Configure callback for title ans progress bar.
        mWebView.setWebChromeClient(new WebChrome());

        // Set the webview configuration.
        WebSettings s = mWebView.getSettings();
        s.setLayoutAlgorithm(WebSettings.LayoutAlgorithm.NARROW_COLUMNS);
        s.setUseWideViewPort(true);
        s.setSavePassword(false);
        s.setSaveFormData(false);
        s.setBlockNetworkLoads(true);
        s.setJavaScriptEnabled(false);

        // Restore if we have a saved instance.
        if (savedInstanceState != null)
            mWebView.restoreState(savedInstanceState);
        else
            showFile(LICENSE_LOCATION);
    }

    @Override
    protected void onResume() {
        super.onResume();

        CookieSyncManager.getInstance().startSync(); 
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        if (mWebView != null)
            mWebView.saveState(outState);
    }

    @Override
    protected void onStop() {
        super.onStop();
        
        CookieSyncManager.getInstance().stopSync(); 
        mWebView.stopLoading();       
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();

        mWebView.destroy();
    }

    /**
     * Displays the given file in the web view.
     *
     * @param path Path of the file to show.
     */
    private void showFile(final String path) {
        final File file = new File(path);

        if (!isFileValid(file)) {
            Log.e(TAG, "License file '" + path + "' does not exist");
            showErrorAndFinish();
            return;
        }

        Uri uri = Uri.fromFile(file);
        mWebView.loadUrl(uri.toString());
    }

    /**
     * Checks whether the given file is valid or not.
     *
     * @param file The file to check.
     *
     * @return {@code true} if the file is valid, {@code false} otherwise.
     */
    boolean isFileValid(final File file) {
        return file.exists() && file.length() != 0;
    }

    /**
     * Displays an error and finishes the activity.
     */
    private void showErrorAndFinish() {
        Toast.makeText(this, R.string.license_error, Toast.LENGTH_LONG).show();
        finish();
    }

    /**
     * Helper class used to manage web viewer actions such as
     * set title and load progress changes.
     */
    class WebChrome extends WebChromeClient {
        
        @Override
        public void onReceivedTitle(WebView view, String title) {
            DigiLicenseActivity.this.setTitle(title);
        }
        
        @Override
        public void onProgressChanged(WebView view, int newProgress) {
            getWindow().setFeatureInt(Window.FEATURE_PROGRESS, newProgress * 100);
            if (newProgress == 100)
                CookieSyncManager.getInstance().sync();
        }
    }
}
