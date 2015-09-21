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

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.IBinder;
import android.view.*;
import android.widget.ArrayAdapter;
import android.widget.CheckedTextView;
import com.phatware.android.recotest.R;


public class DialogHelper {


    private static CharSequence[] languageValues;
    private static CharSequence[] languages;
    private static int activeLang;
    private static final int DEFAULT_LANG_INDEX = 3;
    public static final int[] FLAG_DRAWABLE = {
            R.drawable.flag_da,
            R.drawable.flag_de,
            R.drawable.flag_en_uk,
            R.drawable.flag_en,
            R.drawable.flag_es,
            R.drawable.flag_fr,
            R.drawable.flag_it,
            R.drawable.flag_nl,
            R.drawable.flag_nb,
            R.drawable.flag_pt_br,
            R.drawable.flag_pt_pt,
            R.drawable.flag_sv,
            R.drawable.flag_fi,
            R.drawable.flag_ind,
                       };


    public static AlertDialog createLanguageDialog(final Context context, final IBinder windowToken) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setCancelable(true);
        builder.setIcon(R.drawable.sym_keyboard_done);
        builder.setNegativeButton(android.R.string.cancel, null);

        String language = MainSettings.getLanguage(context);
        if (languages == null) {
            languages = context.getResources().getTextArray(R.array.preference_main_settings_language_list);
        }
        if (languageValues == null) {
            languageValues = context.getResources().getTextArray(R.array.preference_main_settings_language_list_values);
        }

        activeLang = DEFAULT_LANG_INDEX;

        for (int i = 0; i < languageValues.length; i++) {
            if (languageValues[i].toString().equalsIgnoreCase(language)) {
                activeLang = i;
                break;
            }
        }
        final int defaultPadding = context.getResources().getDimensionPixelSize(R.dimen.keyboard_bottom_padding);
        final LayoutInflater layoutInflater = LayoutInflater.from(context);
        builder.setSingleChoiceItems(new ArrayAdapter<String>(context, R.layout.simple_list_item_checked) {

            @Override
            public int getCount() {
                return languages.length;
            }

            @Override
            public String getItem(final int position) {
                return languages[position].toString();
            }

            @Override
            public View getView(final int position, final View convertView, final ViewGroup parent) {
                CheckedTextView view;
                if (convertView == null) {
                    view = (CheckedTextView) layoutInflater.inflate(R.layout.simple_list_item_checked, null, false);
                } else {
                    view = (CheckedTextView) convertView;
                }

                view.setText(getItem(position));
                view.setChecked(position == activeLang);
                view.setCompoundDrawablePadding(defaultPadding);
                view.setCompoundDrawablesWithIntrinsicBounds(context.getResources().getDrawable(FLAG_DRAWABLE[position]), null, null, null);
                return view;
            }
        }, activeLang, new LanguageOnClickListener(context));
        builder.setSingleChoiceItems(languages, activeLang, new LanguageOnClickListener(context));
        builder.setTitle(R.string.preference_main_settings_language_summary);
        AlertDialog mOptionsDialog = builder.create();
        Window window = mOptionsDialog.getWindow();
        WindowManager.LayoutParams lp = window.getAttributes();
        lp.token = windowToken;
        lp.type = WindowManager.LayoutParams.TYPE_APPLICATION_ATTACHED_DIALOG;
        window.setAttributes(lp);
        window.addFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);


        return mOptionsDialog;

    }

    public static AlertDialog createAlternativesDialog(final Context context, final IBinder windowToken, final CharSequence[] alternatives) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setCancelable(true);
        builder.setNegativeButton(android.R.string.cancel, null);

        builder.setItems(alternatives, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialogInterface, int i) {
            }
        });


        builder.setTitle(R.string.alternatives);
        AlertDialog mOptionsDialog = builder.create();
        Window window = mOptionsDialog.getWindow();
        WindowManager.LayoutParams lp = window.getAttributes();
        lp.token = windowToken;
        lp.type = WindowManager.LayoutParams.TYPE_APPLICATION_ATTACHED_DIALOG;
        window.setAttributes(lp);
        window.addFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
        return mOptionsDialog;

    }

    private static class LanguageOnClickListener implements DialogInterface.OnClickListener {
        private final Context context;

        private LanguageOnClickListener(final Context context) {
            this.context = context;
        }


        @Override
        public void onClick(DialogInterface di, int position) {
            di.dismiss();
            if (languageValues == null) {
                languageValues = context.getResources().getTextArray(R.array.preference_main_settings_language_list_values);
            }
            CharSequence languageCharSequence = languageValues[position];
            if (languageCharSequence != null) {
                String lang = languageCharSequence.toString();
                MainSettings.setLanguage(context, lang);
                WritePadManager.setLanguage(lang, context);
            }
        }
    }
}
