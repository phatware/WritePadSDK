/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 1997-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad Android Sample
 *
 * Unauthorized distribution of this code is prohibited. For more information
 * refer to the End User Software License Agreement provided with this 
 * software.
 *
 * This source code is distributed and supported by PhatWare Corp.
 * http://www.phatware.com
 *
 * THIS SAMPLE CODE CAN BE USED  AS A REFERENCE AND, IN ITS BINARY FORM, 
 * IN THE USER'S PROJECT WHICH IS INTEGRATED WITH THE WRITEPAD SDK. 
 * ANY OTHER USE OF THIS CODE IS PROHIBITED.
 * 
 * THE MATERIAL EMBODIED ON THIS SOFTWARE IS PROVIDED TO YOU "AS-IS"
 * AND WITHOUT WARRANTY OF ANY KIND, EXPRESS, IMPLIED OR OTHERWISE,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL PHATWARE CORP.  
 * BE LIABLE TO YOU OR ANYONE ELSE FOR ANY DIRECT, SPECIAL, INCIDENTAL, 
 * INDIRECT OR CONSEQUENTIAL DAMAGES OF ANY KIND, OR ANY DAMAGES WHATSOEVER, 
 * INCLUDING WITHOUT LIMITATION, LOSS OF PROFIT, LOSS OF USE, SAVINGS 
 * OR REVENUE, OR THE CLAIMS OF THIRD PARTIES, WHETHER OR NOT PHATWARE CORP.
 * HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH LOSS, HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, ARISING OUT OF OR IN CONNECTION WITH THE
 * POSSESSION, USE OR PERFORMANCE OF THIS SOFTWARE.
 * 
 * US Government Users Restricted Rights 
 * Use, duplication, or disclosure by the Government is subject to
 * restrictions set forth in EULA and in FAR 52.227.19(c)(2) or subparagraph
 * (c)(1)(ii) of the Rights in Technical Data and Computer Software
 * clause at DFARS 252.227-7013 and/or in similar or successor
 * clauses in the FAR or the DOD or NASA FAR Supplement.
 * Unpublished-- rights reserved under the copyright laws of the
 * United States.  Contractor/manufacturer is PhatWare Corp.
 * 10414 W. Highway 2, Ste 4-121 Spokane, WA 99224
 *
 * ************************************************************************************* */

package com.phatware.android;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.os.Bundle;
import android.preference.Preference;
import android.preference.PreferenceActivity;
import android.preference.PreferenceManager;
import android.util.Log;
import com.phatware.android.recotest.R;

/**
 * User: TIMUR
 * Date: Oct 30, 2010
 * Time: 6:27:59 PM
 */

public class MainSettings extends PreferenceActivity {

    public static final String TAG = "MainSettings";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        try {
            super.onCreate(savedInstanceState);
            addPreferencesFromResource(R.xml.preferences);
            Preference languagePreference = findPreference(getResources().getString(R.string.preference_main_settings_language_key));
            languagePreference.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
                @Override
                public boolean onPreferenceClick(final Preference preference) {
                    try {
                        DialogHelper.createLanguageDialog(MainSettings.this, getWindow().getDecorView().getRootView().getWindowToken()).show();
                    } catch( Throwable e) {
                        Log.e(TAG, e.getMessage(), e);
                    }
                    return true;
                }
            });
            WritePadManager.recoInit(this);
            WritePadFlagManager.initialize(getBaseContext());
        } catch (RuntimeException e) {
            Log.e(TAG, e.getMessage(), e);
            finish();
        } catch (Throwable e) {
            Log.e(TAG, e.getMessage(), e);
            finish();
        }
    }


    public static String getLanguage(Context context) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        return sharedPreferences.getString(context.getResources().getString(R.string.preference_main_settings_language_key), null);
    }

    public static void setLanguage(Context context, String language) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putString(context.getResources().getString(R.string.preference_main_settings_language_key), language);
        editor.commit();
    }

    private static boolean getCheckBoxPreference(Context context, Resources resources, int resourceID, boolean defaultValue) {
        boolean result;
        SharedPreferences preferences = PreferenceManager.getDefaultSharedPreferences(context);
        String key = resources.getString(resourceID);
        result = preferences.contains(key) ? preferences.getBoolean(key, false) : defaultValue;
        return result;
    }


    public static boolean isSeparateLetterModeEnabled(Context context) {
        return getCheckBoxPreference(context, context.getResources(), R.string.preference_recognizer_separate_letters_key, false);
    }


    public static boolean isSingleWordEnabled(Context context) {
        return getCheckBoxPreference(context, context.getResources(), R.string.preference_recognizer_single_word_only_key, false);
    }

    @Override
    public void onBackPressed() {
        finish();
    }
}
