/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2014 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad SDK Sample
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
 * 1314 S. Grand Blvd. Ste. 2-175 Spokane, WA 99202
 *
 * ************************************************************************************* */

#pragma once

// from WritePadViewController.m
#define kGeneralOptionsFirstStartKey		@"GeneralOptionsFirstStartKey"
#define kGenegalOptionsText					@"GenegalOptionsText"
#define kGenegalOptionsTextScrollPos		@"GenegalOptionsTextScrollPos"
#define kGenegalOptionsTextSelStart			@"GenegalOptionsTextSelStart"
#define kGenegalOptionsTextSelLength		@"GenegalOptionsTextSelLength"
#define kGenegalOptionsTextEditOn			@"GenegalOptionsTextEditOn"
#define kGenegalOptionsRecoMode				@"GenegalOptionsRecoMode"
#define kGeneralOptionsDisableRotation		@"GeneralOptionsDisableRotation"
#define kGeneralOptionsFileEncoding			@"GeneralOptionsFileEncoding"
#define kGeneralOptionsFileName				@"GeneralOptionsFileName"
#define kGeneralOptionsFolderName			@"GeneralOptionsFolderName"
#define kGeneralOptionsShowAllFolders		@"GeneralOptionsShowAllFolders"
#define kGeneralOptionsCurrentLanguage		@"GeneralOptionsCurrentLanguage"

#define kWritePadTintColor					@"WritePadTintColor"

// from WritePadEdit.h
#define kEditOptionsShowSuggestions			@"ShowSuggestionWindow"
#define kEditEnableSpellChecker				@"EditEnableSpellChecker"
#define kEditEnableTextAnalyzer				@"EditEnableTextAnalyzer"
#define kEditSetSelectMode					@"EditSetSelectMode"
#define kEditOptionsFontSize				@"EditFontSize"
#define kEditOptionsFontFace				@"EditFontFace"
#define kEditOptionsAutocapitalize			@"EditOptionsAutocapitalize"
#define kEditOptionsAutospace				@"EditOptionsAutospace"
#define kEditShowScrollButtons				@"EditShowScrollButtons"
#define kEditHideToolbar					@"EditHideToolbar"
#define kEditSearchMatchCase				@"EditSearchMatchCase"
#define kEditTextColor						@"EditTextColor"
#define kEditPageColor						@"EditPageColor"
#define kEditInkColor						@"EditInkColor"
#define kEditOptionsAlignment				@"EditOptionsAlignment"
#define kEditOptionsCustomStyles			@"EditOptionsCustomStyles"
#define kOptionsDocumentSortOrder			@"OptionsDocumentSortOrder"
#define kEditShowDocumentEnd                @"EditShowDocumentEnd"

#define kGeneralOptionsSearchHandwriting    @"GeneralOptionsSearchHandwriting"
#define kGeneralOptionsInputMode			@"GeneralOptionsInputMode"
#define kGeneralOptionsCurrentPageSize      @"GeneralOptionsCurrentPageSize"
#define kGeneralOptionsCurrentPageSizeHeight @"GeneralOptionsCurrentPageSizeHeight"
#define kGeneralOptionsCurrentPageSizeWidth @"GeneralOptionsCurrentPageSizeWidth"

#define kRecoOptionsFirstStartKey           @"RecoOptionsFirstStartKey1"

// from InkCollectorView.h
#define kRecoOptionsAsyncRecoEnabled		@"EnableAsyncRecognizer"
#define kRecoOptionsInkWidth				@"RecoInkWidth"
#define kRecoOptionsSeparateLetters			@"RecoSeparateLettersMode"
#define kRecoOptionsSingleWordOnly			@"RecoDisableSegmentation"
#define kRecoOptionsInternational			@"RecoInternationalCharset"
#define kRecoOptionsDictOnly				@"RecoDictionaryOnly"
#define kRecoOptionsSuggestDictOnly			@"RecoDictionaryOnlySuggest"
#define kRecoOptionsUseUserDict				@"RecoEnableUserDict"
#define kRecoOptionsUseLearner				@"RecoUseLearner"
#define kRecoOptionsAsyncInking				@"EnableAsyncInkCollectpor"
#define kRecoOptionsTimerDelay				@"RecoTimerDelay"
#define kRecoOptionsBackstrokeLen			@"RecoBackstrokeLen"
#define kRecoOptionsInkColor				@"RecoInkColor"
#define kRecoOptionsDrawGrid				@"RecoDrawGrid"
#define kRecoOptionsUseCorrector			@"RecoUseCorrector"
#define kRecoOptionsErrorVibrate			@"RecoErrorVibrate"
#define kRecoOptionsSpellIgnoreNum			@"RecoOptionsSpellIgnoreNum"
#define kRecoOptionsSpellIgnoreUpper		@"RecoOptionsSpellIgnoreUpper"
#define kRecoOptionsInsertResult			@"RecoOptionsInsertResult"
#define kRecoOptionsLetterShapes			@"RecoOptionsLetterShapes"
#define kRecoOptionsAutoInsertResult        @"RecoOptionsAutoInsertResult"
#define kRecoOptionsSystemShorthands        @"RecoOptionsSystemShorthands"
#define kRecoOptionsSystemGestures          @"RecoOptionsSystemGestures"
#define RecoOptionsSettingsID               @"RecoOptionsSettingsID_2674"
#define kRecoOptionsDetectNewLine           @"RecoOptionsDetectNewLine"
#define kUniqueApplicationID				@"UniqueApplicationID"
#define kRecoOptionsSmartPunctuationSpace   @"RecoOptionsSmartPunctuationSpace"

#define kGeneralOptionsGroupEvents			@"GeneralOptionsGroupEvents"
#define kGeneralOptionsGroupNotes			@"GeneralOptionsGroupNotes"
#define kGeneralOptionsGroupVoiceNotes		@"GeneralOptionsGroupVoiceNotes"
#define kGeneralOptionsGroupTasks			@"GeneralOptionsGroupTasks"
#define kGeneralOptionsGroupFolders			@"GeneralOptionsGroupFolders"
#define kGeneralOptionsTaskColors			@"GeneralOptionsTaskColors"
#define kGeneralOptionsEventColors			@"GeneralOptionsEventColors"
#define kGeneralOptionsNoteColors			@"GeneralOptionsNoteColors"
#define kGeneralOptionsNotePrivate			@"GeneralOptionsNotePrivate"
#define kGeneralOptionsNoteSubjectOnly		@"GeneralOptionsNoteSubjectOnly"
#define kGeneralOptionsVoiceNoteColors		@"GeneralOptionsVoiceNoteColors"
#define kGeneralOptionsNotePropBtn			@"GeneralOptionsNotePropBtn"
#define kGeneralOptionsShowSubject			@"GeneralOptionsShowSubject"

#define kGeneralOptionsLocationKey			@"GeneralOptionsLocationKey"
#define kGeneralOptionsShowSearch			@"GeneralOptionsShowSearch"
#define kGeneralOptionsSearchText			@"GeneralOptionsSearchText"
#define kGeneralOptionsLocalCopyPaste		@"GeneralOptionsLocalCopyPaste"
#define kGeneralOptionsReplaceText          @"GeneralOptionsReplaceText"

#define kTasksOptionsExportFile				@"TasksOptionsExportFile"

#define kGeneralOptionsShowCompleted		@"GeneralOptionsShowCompleted"
#define kGeneralOptionsShowPrivateTasks		@"GeneralOptionsShowPrivateTasks"
#define kGeneralOptionsShowPrivateNotes		@"GeneralOptionsShowPrivateNotes"
#define kGeneralOptionsShowPrivateEvents	@"GeneralOptionsShowPrivateEvents"
#define kGeneralOptionsShowPrivateVoice		@"GeneralOptionsShowPrivateVoice"
#define kGeneralOptionsHideCompleteBox		@"GeneralOptionsHideCompleteBox"
#define kGeneralOptionsShowCancelled		@"GeneralOptionsShowCancelled"
#define kGeneralOptionsDefaultIcon			@"GeneralOptionsDefaultIcon"
#define kGeneralOptionsShowPastDueBadge		@"GeneralOptionsShowPastDueBadge"

#define kJournalOptionsExportFile			@"JournalOptionsExportFile"
#define kGeneralOptionsShowMiscFields		@"GeneralOptionsShowMiscFields"
#define kGeneralOptionsCreateDefaultItems	@"GeneralOptionsCreateDefaultItems"

#define kGeneralOptionsEnableFileShare		@"GeneralOptionsEnableFileShare"
#define kGeneralOptionsEnableDataSync		@"GeneralOptionsEnableDataSync"
#define kGeneralOptionsHttpStayAwake		@"GeneralOptionsHttpStayAwake"
#define kGeneralOptionsEnableFilePassword	@"GeneralOptionsEnableFilePassword"
#define kGeneralOptionsHttpPassword			@"GeneralOptionsHttpPassword"
#define kGeneralOptionsUseKeyboard			@"GeneralOptionsUseKeyboard"

#define kRemoteNotificationsID				@"RemoteNotificationsID"
#define kRemoteNotificationsTMZ				@"RemoteNotificationsTMZ"

#define kOptionsFilterByPriority			@"OptionsFilterByPriority"
#define kOptionsFilterByDate				@"OptionsFilterByDate"
#define kOptionsFilterByText				@"OptionsFilterByDate"
#define kOptionsFilterByColor				@"OptionsFilterByColor"

#define kGeneralOptionsDefaultEmailTO		@"GeneralOptionsDefaultEmailTO"
#define kGeneralOptionsDefaultEmailCC		@"GeneralOptionsDefaultEmailCC"
#define kGeneralOptionsDefaultEmailBCC		@"GeneralOptionsDefaultEmailBCC"
#define kGeneralOptionsDefaultNoteColor		@"GeneralOptionsDefaultNoteColor"
#define kGeneralOptionsDefaultFolderColor	@"GeneralOptionsDefaultFolderColor"
#define kGeneralOptionsDefaultNoteCategoty	@"GeneralOptionsDefaultNoteCategoty"
#define kGeneralOptionsDefaultNotePriority	@"GeneralOptionsDefaultNotePriority"
#define kGeneralOptionsShowGroupsView		@"GeneralOptionsShowGroupsView"
#define kGeneralOptionsFileFormat			@"GeneralOptionsFileFormat"
#define kPhatPadOptionsGridSnap             @"PhatPadOptionsGridSnap"

#define kGeneralOptionsUseFilterCatrgory	@"GeneralOptionsFilterCatrgory"
#define kGeneralOptionsUseFilterColor		@"GeneralOptionsFilterColor"
#define kGeneralOptionsUseFilterPriority	@"GeneralOptionsFilterPriority"
#define kGeneralOptionsDefaultEmailSign		@"GeneralOptionsDefaultEmailSign"
#define kGeneralOptionsInitDefaults			@"GeneralOptionsInitDefaults1818"

#define kOptionsShareUserData				@"OptionsShareUserData"
#define kOptionsShareDataOniCloud           @"OptionsShareDataOniCloud"

#define kTranslatorCreateNew				@"TranslatorCreateNew"
#define kGeneralOptionsDefaultNoteIcon		@"GeneralOptionsDefaultNoteIcon"
#define kGeneralOptionsDefaultFolderIcon	@"GeneralOptionsDefaultFolderIcon"

#define EDITCTL_RELOAD_OPTIONS				(@"EDITCTL_RELOAD_OPTIONS")
	
#define kDropboxLastSyncDate				@"DropboxLastSyncDate"
#define kDropboxAutosyncStart				@"DropboxAutosyncStart"
#define kSyncServiceEnabled                 @"SyncServiceEnabled"

#define kFacebookPrivacySetting				@"FacebookPrivacySetting"
#define kFacebookShowTruncateWarning		@"FacebookShowTruncateWarning"
#define kFacebookRememberPassword			@"FacebookRememberPassword"
#define kFacebookEraseAfterUpdate			@"FacebookEraseAfterUpdate"

#define kPhatPadOptionsEnableShapes			@"PhatPadOptionsEnableShapes"
#define kPhatPadOptionsDeleteRecStrokes		@"PhatPadOptionsDeleteRecStrokes"
#define kPhatPadOptionsInkWidth				@"PhatPadOptionsInkWidth"
#define kPhatPadOptionsInkColor				@"PhatPadOptionsInkColor"
#define kPhatPadOptionsDrawGridV			@"PhatPadOptionsDrawGridV"
#define kPhatPadOptionsDrawGridH			@"PhatPadOptionsDrawGridH"
#define kPhatPadOptionsSpaceGridV           @"PhatPadOptionsSpaceGridV"
#define kPhatPadOptionsSpaceGridH           @"PhatPadOptionsSpaceGridH"
#define kPhatPadOptionsIgnoreShortStrokes	@"PhatPadOptionsIgnoreShortStrokes"
#define kPhatPadOptionsPalmRest             @"PhatPadOptionsPalmRest"
#define kPhatPadOptionsPalmRestFirst        @"PhatPadOptionsPalmRestFirst"
#define kPhatPadOptionsAdvancedInking		@"PhatPadOptionsAdvancedInking"
#define kPhatPadOptionsCustomPens			@"PhatPadOptionsCustomPens"
#define kPhatPadOptionsEnableEraseGesture	@"PhatPadOptionsEnableEraseGesture"
#define kPhatPadOptionsInputMode			@"PhatPadOptionsInputMode"

#define kPhatPadSwipeEnabled			    @"PhatPadSwipeEnabled"

#define kPhatPadPageColor					@"PhatPadPageColor"
#define kPresentationSoundEnabled			@"PresentationSoundEnabled"

// Evernote
#define kSyncConflictResolution				@"SyncConflictResolution"
#define kEvernoteDefaultNotebook			@"EvernoteDefaultNotebook"
#define kGeneralOptionsDontShowWizard       @"GeneralOptionsDontShowWizard14"
#define kWritePadSyncPlaySound              @"WritePadSyncPlaySound"

#define kTextFontStyleView                  @"TextFontStyleView"
#define kTextSearchStyleView                @"TextSearchStyleView"

#define kCenterStylusPosition               @"CenterStylusPosition"
#define kCenterStylusPressure               @"CenterStylusPressure"
#define kCenterStylusPalmRest               @"CenterStylusPalmRest"
#define kCenterStylusCmdButton1             @"CenterStylusCmdButton1"
#define kCenterStylusCmdButton2             @"CenterStylusCmdButton2"
#define kCenterStylusCmdFeedback            @"CenterStylusCmdFeedback"
#define kCenterStylusEnable                 @"CenterStylusEnable"
#define kTwoFingerScroolZoom                @"TwoFingerScroolZoom"

#define kVoiceSpeakWhileWriting             @"VoiceSpeakWhileWriting"
#define kVoiceSpeakingSpeed                 @"VoiceSpeakingSpeed"
#define kVoiceSpeakingPitch                 @"VoiceSpeakingPitch"
#define kVoiceSpeakingVolume                @"VoiceSpeakingVolume"
#define kVoiceSpeakingVoice                 @"VoiceSpeakingVoice"

#define kColorPaletteLoadFixedColors        @"ColorPaletteLoadFixedColors"
#define kWritePanelStyle                    @"WritePanelStyle"
#define kInputPanelMarkerPosition           @"InputPanelMarkerPosition"
#define kInputPanelWriteHere                @"InputPanelWriteHere"
#define kTextEditDateFomratID               @"TextEditDateFomratID"
#define kTextEditCustomDateFomratString     @"TextEditCustomDateFomratString"

#define kWriteProUpdateKey                  @"WriteProUpdateKey"
#define kWritePadInstalledDate              @"WritePadInstalledDate"
#define kWritePadStartCount                 @"WritePadStartCount"

#define AD_TIME_INTERVAL                    (60.0 * 60.0 * 24.0 * 10.0)   // 5 DAYS....
#define AD_SHOW_COUNT                       4
#define AD_DISABLED_CODE                    5

#define kEvernoteLastSyncDate               @"EvernoteLastSyncDate"
#define kBoxLastSyncDate                    @"BoxLastSyncDate"
#define kDropboxLastSyncDate                @"DropboxLastSyncDate"
#define kOneDriveLastSyncDate               @"OneDriveLastSyncDate"
#define kGoogleDriveLastSyncDate            @"GoogleDriveLastSyncDate"

#define kPhatCloudSortIndex                 @"PhatCloudSortIndex"
#define kRecoKeyboardCustomKey              @"RecoKeyboardCustomKey"

#define kWritePadPersistentDataDate         @"WritePadPersistentDataDate"


