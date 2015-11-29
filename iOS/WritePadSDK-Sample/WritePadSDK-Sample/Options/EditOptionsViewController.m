/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 1997-2015 PhatWare(r) Corp. All rights reserved.                 * */
/* ************************************************************************************* */

/* ************************************************************************************* *
 *
 * WritePad Input Panel Sample
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
 * 530 Showers Drive Suite 7 #333 Mountain View, CA 94040
 *
 * ************************************************************************************* */

#include <sys/types.h>
#include <sys/sysctl.h>

#import "EditOptionsViewController.h"
#import "WordListEditViewController.h"
#import "DictEditViewController.h"
#import "SourceCell.h"
#import "UIConst.h"
#import "OptionKeys.h"
#import "LetterShapesController.h"
#import "WritePadInputPanel.h"
#import "LanguageManager.h"
#import "RecognizerManager.h"
#import "Shortcuts.h"

@implementation EditOptionsViewController

@synthesize showDone;

static NSString * kDisplayCell_ID = @"DisplayCell_ID";
static NSString * kEditCell_ID = @"WMEditSectionEditSettingsID";

- (id)init
{
	self = [super init];
	if (self)
	{
		showDone = NO;
	}
	return self;
}

#pragma mark Create Controls

- (void)create_switches
{
	for ( int i = 0; i < kUITotalSwitch_Sections; i++ )
	{
		CGRect frame = CGRectMake(0.0, 0.0, kSwitchButtonWidth, kSwitchButtonHeight);
		switchCtl[i] = [[UISwitch alloc] initWithFrame:frame];
		[switchCtl[i] addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
		
		// in case the parent view draws with a custom color or gradient, use a transparent color
		switchCtl[i].backgroundColor = [UIColor clearColor];
	}
}

- (void)switchAction:(id)sender
{
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
		
	if ( sender == switchCtl[kUIInsertResult_Section] )
		[defaults setBool:[sender isOn] forKey:kRecoOptionsInsertResult];
	if ( sender == switchCtl[kUISingleWord_Section] )
		[defaults setBool:[sender isOn]  forKey:kRecoOptionsSingleWordOnly];
	if ( sender == switchCtl[kUISeparateLetters_Section] )
		[defaults setBool:[sender isOn]  forKey:kRecoOptionsSeparateLetters];
	if ( sender == switchCtl[kUIAutospace_Section] )
		[defaults setBool:(![sender isOn])  forKey:kEditOptionsAutospace];
	if ( sender == switchCtl[kUIOnlyDictWords_Section] )
		[defaults setBool:[sender isOn]  forKey:kRecoOptionsDictOnly];
	if ( sender == switchCtl[kUIUseUserDict_Section] )
		[defaults setBool:[sender isOn] forKey:kRecoOptionsUseUserDict];
	if ( sender == switchCtl[kUIUseLearner_Section] )
		[defaults setBool:[sender isOn] forKey:kRecoOptionsUseLearner];
	if ( sender == switchCtl[kUIUseCorrector_Section] )
		[defaults setBool:[sender isOn] forKey:kRecoOptionsUseCorrector];
    if (sender == switchCtl[kUIDetectNewLine_Section] )
        [defaults setBool:[sender isOn] forKey:kRecoOptionsDetectNewLine];
}

- (Boolean) isPhone
{
	int		mib[2];
	char	szTmp[100] = "";
	size_t len;
	
	mib[0] = CTL_HW;
	mib[1] = HW_MACHINE;
	len = sizeof(szTmp);
	int res = sysctl(mib, 2, &szTmp, &len, NULL, 0);
	if ( res == 0 )
	{	
		if ( strncmp( szTmp, "iPhone", 6 ) == 0 )
			return TRUE;
	}
	return FALSE;
}

#pragma mark Initialize View

- (void)loadView
{
    [super loadView];
	// Custom initialization
	if ( showDone )
	{
		buttonItemDone = [[UIBarButtonItem alloc] 
						  initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
		self.navigationItem.leftBarButtonItem = buttonItemDone;
	}

    // this title will appear in the navigation bar
    self.title = NSLocalizedString( @"Settings", @"" );
	
	[self create_switches];
}

- (IBAction)doneAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIViewController delegate methods

// called after this controller's view was dismissed, covered or otherwise hidden
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];	
		
}

// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
		
	NSUserDefaults*	defaults = [NSUserDefaults standardUserDefaults];
	switchCtl[kUIInsertResult_Section].on = [defaults boolForKey:kRecoOptionsInsertResult];
	switchCtl[kUISeparateLetters_Section].on = [defaults boolForKey:kRecoOptionsSeparateLetters];
	switchCtl[kUIAutospace_Section].on = (![defaults boolForKey:kEditOptionsAutospace]);
	switchCtl[kUISingleWord_Section].on = [defaults boolForKey:kRecoOptionsSingleWordOnly];
	switchCtl[kUIOnlyDictWords_Section].on = [defaults boolForKey:kRecoOptionsDictOnly];
	switchCtl[kUIUseUserDict_Section].on = [defaults boolForKey:kRecoOptionsUseUserDict];
	switchCtl[kUIUseLearner_Section].on = [defaults boolForKey:kRecoOptionsUseLearner];
	switchCtl[kUIUseCorrector_Section].on = [defaults boolForKey:kRecoOptionsUseCorrector];
    switchCtl[kUIDetectNewLine_Section].on =[defaults boolForKey:kRecoOptionsDetectNewLine];
	
	[self.tableView reloadData];
}

#pragma mark - UITableView delegates

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return kUITotal_Sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	NSString *title = @"";
	switch( section )
	{
		case kUIUseLearner_Section :
			title = NSLocalizedString( @"Recognizer Settings", @"" );
			break;
			
		case kUIOnlyDictWords_Section :
			title = NSLocalizedString( @"Dictionary Settings", @"" );
			break;
            
		case kUIUseLanguage_Section :
			title = NSLocalizedString( @"Language", @"" );
			break;
	}
	return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if ( section == kUIShapeSelector_Section || section == kUIUseLanguage_Section  )
    {
		return 1;
    }
	if ( (section == kUIUseUserDict_Section || section == kUIUseCorrector_Section) )
    {
		return 3;
    }
	return 2;
}

// to determine specific row height for each cell, override this.  In this example, each row is determined
// buy the its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = kUIRowHeight;
	if ( ([indexPath section] == kUIUseUserDict_Section || [indexPath section] == kUIUseCorrector_Section) && [indexPath row] == 2 )
		result = kWordCellHeight;
	else if ( [indexPath row] == 1 )
		result = kUIRowLabelHeight;
	else if ( [indexPath row] == 2 )
		result = kUIRowLabelHeight;
	return result;
}

// utility routine leveraged by 'cellForRowAtIndexPath' to determine which UITableViewCell to be used on a given row
//
- (UITableViewCell *)obtainTableCellForTable:(UITableView*)tableView withRow:(NSInteger)row
{
	UITableViewCell *cell = nil;
	
	if (row == 0)
		cell = [tableView dequeueReusableCellWithIdentifier:kDisplayCell_ID];
	else if (row == 1 )
		cell = [tableView dequeueReusableCellWithIdentifier:kSourceCell_ID];
	else 
		cell = [tableView dequeueReusableCellWithIdentifier:kEditCell_ID];
	
	if (cell == nil)
	{
		if (row == 0 )
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kDisplayCell_ID];
		else if (row == 1 )
			cell = [[SourceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSourceCell_ID];
		else
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEditCell_ID];
	}
	return cell;
}

// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];				
	UITableViewCell *cell = nil;
	
	if ( indexPath.section == kUIShapeSelector_Section ||
        indexPath.section == kUIUseLanguage_Section )
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kEditCell_ID];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kEditCell_ID];
		}
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch( indexPath.section )
        {
            case kUIShapeSelector_Section :
                cell.textLabel.text = NSLocalizedString( @"Letter Shapes", @"" );
                break;
                
            case kUIUseLanguage_Section :
                cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString( @"Language: %@", @"" ), [[LanguageManager sharedManager] languageName:WPLanguageUnknown]];
                break;
        }
		return cell;
	}
	
	cell = [self obtainTableCellForTable:tableView withRow:row];
	switch( indexPath.section )
	{
		case kUIUseLearner_Section :
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				cell.textLabel.text = NSLocalizedString( @"Auto Learner", @"" );
				cell.accessoryView = switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, recognizer will learn your handwriting patterns.", @"" );
			}	
			break;

		case kUIUseCorrector_Section :
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				cell.textLabel.text = NSLocalizedString( @"Autocorrector", @"" );
				cell.accessoryView = switchCtl[indexPath.section];
			}
			else if ( row == 1 )
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, common spelling errors automatically corrected.", @"" );
			}	
			else 
			{
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text = NSLocalizedString( @"Edit Autocorrector List", @"" );
				// cell.imageView.image = [UIImage imageNamed:@"scroll_replace.png"];
			}
			break;
			
		case  kUIAutospace_Section :
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				cell.textLabel.text = NSLocalizedString( @"Add Space", @"" );
				cell.accessoryView = switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, a space is added at the end.", @"" );
			}
			break;
			
		case  kUISeparateLetters_Section :
			if (row == 0)
			{
				// this cell hosts the UISwitch control
				cell.textLabel.text = NSLocalizedString( @"Separate Letters", @"" );
				cell.accessoryView = switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, do not connect individual letters.", @"" );
			}
			break;
			
		case kUISingleWord_Section :
			if (row == 0)
			{
				// this cell hosts the UIPageControl control
				cell.textLabel.text = NSLocalizedString( @"Single Word Only", @"" );
				cell.accessoryView =  switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, write one word per recognition session.", @"" );
			}
			break;
            
        case kUIDetectNewLine_Section :
			if (row == 0)
			{
				// this cell hosts the UIPageControl control
				cell.textLabel.text = NSLocalizedString( @"Detect New Line", @"" );
				cell.accessoryView =  switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, new line is detected when recognizing handwriting.", @"" );
			}
			break;            
			
		case kUIInsertResult_Section :
			if (row == 0)
			{
				// this cell hosts the UIPageControl control
				cell.textLabel.text = NSLocalizedString( @"Continuous Writing", @"" );
				cell.accessoryView =  switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"Inserts recognized text when starting a new line left of marker.", @"" );
			}
			break;
			
		case kUIOnlyDictWords_Section :
			if (row == 0)
			{
				// this cell hosts the UIPageControl control
				cell.textLabel.text = NSLocalizedString( @"Only Known Words", @"" );
				cell.accessoryView =  switchCtl[indexPath.section];
			}
			else
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, only dictionary words are recognized.", @"" );
			}
			break;
			
		case kUIUseUserDict_Section :
			if (row == 0)
			{
				// this cell hosts the UIPageControl control
				cell.textLabel.text = NSLocalizedString( @"User Dictionary", @"" );
				cell.accessoryView =  switchCtl[indexPath.section];
			}
			else if ( row == 1 )
			{
				// this cell hosts the info on where to find the code
				((SourceCell *)cell).sourceLabel.text = NSLocalizedString( @"If ON, user dictionary is enabled.", @"" );
			}
			else 
			{
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text = NSLocalizedString( @"Edit User Dictionary", @"" );
				// cell.imageView.image = [UIImage imageNamed:@"dictionary.png"];
			}
			break;
    }
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSInteger row = [indexPath row];
	switch( indexPath.section )
	{
		case kUIUseUserDict_Section :
			switch ( row )
			{				
				case 2 :
					{
						DictEditViewController *viewController = [[DictEditViewController alloc] init];
						[self.navigationController pushViewController:viewController animated:YES];
					}
					break;
			}
			break;
			
		case kUIUseCorrector_Section :
			switch ( row )
			{
				case 2 :
					{
                        WordListEditViewController *viewController = [[WordListEditViewController alloc] init]; // ]WithStyle:UITableViewStylePlain];
						[self.navigationController pushViewController:viewController animated:YES];
					}
					break;
			}
			break;
			
		case kUIShapeSelector_Section :
			switch ( row )
			{
				case 0 :
					{
						LetterShapesController *viewController = [[LetterShapesController alloc] init];
						[self.navigationController pushViewController:viewController animated:YES];	
					}
					break;
			}
			break;
			
        case kUIUseLanguage_Section :
			switch ( row )
            {
                case 0 :
                    {
                        // select language
                        LanguageSelectorController *viewController = [[LanguageSelectorController alloc] initWithStyle:(UITableViewStylePlain)];
                        LanguageManager * langman = [LanguageManager sharedManager];
                        NSArray * langs = [langman supportedLanguages];
                        NSMutableArray * arrayLang = [NSMutableArray arrayWithCapacity:[langs count]];
                        NSInteger index = 0;
                        NSDictionary * language;
                        
                        WPLanguage currentLanguage = langman.currentLanguage;
                        viewController.selectedIndex = index;
                        
                        for ( NSNumber * l in langs )
                        {
                            WPLanguage lang = [langman languageIDFromLanguageCode:[l intValue]];
                            UIImage * image = [langman languageImageForLanguageID:lang];
                            NSString * name = [langman languageName:lang];
                            language = @{ @"name" : name, @"ID" : [NSNumber numberWithInt:lang], @"image" : image };
                            [arrayLang addObject:language];
                            if ( currentLanguage == lang )
                                viewController.selectedIndex = index;
                            index++;
                        }
                        
                        viewController.choices = arrayLang;
                        viewController.delegate = self;
                        viewController.tag = 1;
                        viewController.strTitle = NSLocalizedString( @"Language", @"" );
                        [self.navigationController pushViewController:viewController animated:YES];
                    }
                    break;
            }
			break;
			
			
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

#pragma mark - Slect new language

- (void) itemSelected:(LanguageSelectorController *)viewController itemName:(NSString *)strItem itemIndex:(NSInteger)nItem
{
	NSInteger lcurrent = [[NSUserDefaults standardUserDefaults] integerForKey:kGeneralOptionsCurrentLanguage];
    NSInteger language = lcurrent;
    
    for ( WPLanguage l = WPLanguageEnglishUS; l <= WPLanguageMedicalUS; l++ )
    {
        if ( [strItem isEqualToString:[[LanguageManager sharedManager] languageName:l]] )
        {
            language = l;
            break;
        }
    }

    if ( lcurrent != language )
    {
        int mode = [[RecognizerManager sharedManager] getMode];
        [[RecognizerManager sharedManager] disable:YES];
        [[NSUserDefaults standardUserDefaults] setInteger:language forKey:kGeneralOptionsCurrentLanguage];
        [[RecognizerManager sharedManager] enable];
        [[RecognizerManager sharedManager] setMode:mode];

        [[NSUserDefaults standardUserDefaults] setInteger:language forKey:kGeneralOptionsCurrentLanguage];
	}
	[self.tableView reloadData];
}

#pragma mark -

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] postNotificationName:EDITCTL_RELOAD_OPTIONS object:nil];
}


@end
