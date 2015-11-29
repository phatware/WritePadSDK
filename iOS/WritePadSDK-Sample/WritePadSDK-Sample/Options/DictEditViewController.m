/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 1997-2012 PhatWare(r) Corp. All rights reserved.                 * */
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
 * 10414 W. Highway 2, Ste 4-121 Spokane, WA 99224
 *
 * ************************************************************************************* */

#import "DictEditViewController.h"
#import "UIConst.h"
#import "RecognizerManager.h"

static NSString *kCellIdentifier = @"DictCellIdentifier";

@interface DictEditViewController()
{
    UITextField *		 newWordField;
    CellTextField	*	 newWordCell;

    UIBarButtonItem *	 buttonItemEdit;
    UIBarButtonItem *	 buttonItemDone;
    Boolean				_bDictModified;
    NSMutableArray  *   _sections;
}

@property (nonatomic, retain) NSMutableArray *	 userWords;

@end

@implementation DictEditViewController

- (id)init
{
	self = [super init];
	if (self)
	{
		// this title will appear in the navigation bar
		self.title = NSLocalizedString( @"User Dictionary", @"" );
		self.userWords = [NSMutableArray array];
        _sections = [[NSMutableArray alloc] init];
		_bDictModified = NO;
	}
	return self;
}

- (UITextField *)createTextField
{
	CGRect frame = CGRectMake(0.0, 0.0, kTextFieldWidth, kTextFieldHeight);
	UITextField *returnTextField = [[UITextField alloc] initWithFrame:frame];
    
	returnTextField.borderStyle = UITextBorderStyleRoundedRect;
    returnTextField.textColor = [UIColor blackColor];
	returnTextField.font = [UIFont systemFontOfSize:17.0];
    returnTextField.placeholder = NSLocalizedString( @"<enter new word>", @"" );
    returnTextField.backgroundColor = [UIColor whiteColor];
	returnTextField.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	returnTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	
	returnTextField.keyboardType = UIKeyboardTypeDefault;
	returnTextField.returnKeyType = UIReturnKeyDone;
	
	returnTextField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	return returnTextField;
}


- (void) reloadDictionary
{
	// init word list
	[_userWords removeAllObjects];

    self.userWords = [[RecognizerManager sharedManager] getUserWords];
    [self recalcSections];
    [self.tableView reloadData];
}

- (void) recalcSections
{
    [_sections removeAllObjects];
    if ( [self.tableView isEditing] )
    {
        [_sections insertObject:@{ @"name"   : @"+",
                                   @"index"  : [NSNumber numberWithInteger:0],
                                   @"length" : [NSNumber numberWithInteger:1] } atIndex:0];
    }
    if ( [_userWords count] < 1 )
        return;
    
    unichar chr, ch0 = tolower( [[_userWords objectAtIndex:0] characterAtIndex:0] );
    int index0 = 0;
    // create sections for indexing
    for ( int i = 1; i < [_userWords count]; i++ )
    {
        NSString * item = [_userWords objectAtIndex:i];
        chr = tolower( [item characterAtIndex:0] );
        if ( chr != ch0 )
        {
            [_sections addObject:@{ @"name"   : [NSString stringWithCharacters:&ch0 length:1],
                                    @"index"  : [NSNumber numberWithInteger:index0],
                                    @"length" : [NSNumber numberWithInteger:i-index0] }];
            index0 = i;
            ch0 = chr;
        }
    }
    if ( index0 < [_userWords count] )
    {
        [_sections addObject:@{ @"name"   : [NSString stringWithCharacters:&ch0 length:1],
                                @"index"  : [NSNumber numberWithInteger:index0],
                                @"length" : [NSNumber numberWithInteger:[_userWords count]-index0] }];
    }
}


#pragma mark Initialize View

- (void)loadView
{
	[super loadView];
	
	// setup our parent content view and embed it to your view controller
	buttonItemEdit = [[UIBarButtonItem alloc]
					  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction)];
	buttonItemDone = [[UIBarButtonItem alloc]
					  initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
	
	newWordField = [self createTextField];
    
	// create and configure the table view
	self.tableView.autoresizesSubviews = YES;
    
	// tableDict.editing = YES;
    self.tableView.sectionIndexBackgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
	_bDictModified = NO;
}

- (IBAction)editAction
{
    [_sections insertObject:@{ @"name"   : @"+",
                               @"index"  : [NSNumber numberWithInteger:0],
                               @"length" : [NSNumber numberWithInteger:1] } atIndex:0];
    self.navigationItem.rightBarButtonItem = buttonItemDone;
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
    [self.tableView setEditing:YES animated:YES];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:NO];
}

- (IBAction)doneAction
{
	// if ( [newWordField isFirstResponder] )
	[newWordField resignFirstResponder];
    [self.tableView setEditing:NO animated:YES];
    self.navigationItem.rightBarButtonItem = buttonItemEdit;
    [_sections removeObjectAtIndex:0];
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark UIViewController delegate methods

// called after this controller's view was dismissed, covered or otherwise hidden
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if ( [self.tableView isEditing] )
		[self.tableView setEditing:NO animated:NO];
	if ( nil != self.navigationItem.rightBarButtonItem )
		self.navigationItem.rightBarButtonItem = nil;
	
	// if ( [newWordField isFirstResponder] )
	[newWordField resignFirstResponder];
	
	if ( _bDictModified )
	{
		// save the word list now
        [[RecognizerManager sharedManager] newUserDictFromWordList:self.userWords];
		_bDictModified = NO;
	}
	// _recognizer = NULL;
}

// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self reloadDictionary];

    self.navigationItem.rightBarButtonItem = [self.tableView isEditing] ? buttonItemDone : buttonItemEdit;
}

#pragma mark - UITableView delegates

// if you want the entire table to just be re-orderable then just return UITableViewCellEditingStyleNone
//

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	NSInteger sections = [_sections count];
    return sections;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// NSString *title = (_recognizer==nil) ? NSLocalizedTableTitle( @"Recognizer Not Loaded..." ) : nil;
	return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger nRes = 0;
	if ( section  < [_sections count] )
	{
		nRes = [[[_sections objectAtIndex:section] objectForKey:@"length"] integerValue];
	}
	return nRes;
}

// to determine specific row height for each cell, override this.  In this example, each row is determined
// buy the its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat result = ([tableView isEditing] && [indexPath row] == 0) ? kNewWordCellHeight : kWordCellHeight;
	return result;
}


// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSInteger row = [indexPath row];
	NSInteger section = [indexPath section];
	UITableViewCell *cell = nil;
    
    
	if ( [tableView isEditing] && section == 0 )
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kCellTextField_ID];
		if ( cell == nil )
		{
			cell = [[CellTextField alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellTextField_ID];
			((CellTextField *)cell).delegate = self;	// so we can detect when cell editing starts
		}
		newWordField.text = @"";
		cell.editingAccessoryType = UITableViewCellAccessoryNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		((CellTextField *)cell).view = newWordField;
		newWordCell = (CellTextField *)cell;	// kept track for editing
	}
	else
	{
		cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
		if ( cell == nil )
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
		}
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.editingAccessoryType = UITableViewCellAccessoryNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = @"";
        
        if ( section < [_sections count] )
        {
            NSInteger index = [[[_sections objectAtIndex:section] objectForKey:@"index"] integerValue] + row;
            if ( index < [_userWords count] )
            {
                cell.textLabel.text = [_userWords objectAtIndex:index];
            }
        }
	}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( [self.tableView isEditing] )
	{
		if (indexPath.section == 0 )
		{
			return UITableViewCellEditingStyleInsert;
		}
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ( [tableView isEditing] )
	{
        NSInteger index = [[[_sections objectAtIndex:indexPath.section] objectForKey:@"index"] integerValue] + indexPath.row;
		if (editingStyle == UITableViewCellEditingStyleDelete)
		{
			[_userWords removeObjectAtIndex:index];
            NSInteger sections = [_sections count];
            [self recalcSections];
            if ( sections > [_sections count] )
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            else
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			_bDictModified = YES;
		}
		else if (editingStyle == UITableViewCellEditingStyleInsert)
		{
			if ( [newWordField.text length] > 0 )
			{
				// if ( [newWordField isFirstResponder] )
				[newWordField resignFirstResponder];
				NSMutableString * str = [NSMutableString stringWithString:newWordField.text];
				NSUInteger len = [str length];
				[str replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, len)];
				[_userWords insertObject:str atIndex:0];
                [self recalcSections];
				[tableView reloadData];
				_bDictModified = YES;
				newWordField.text = @"";
			}
		}
	}
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSMutableArray * arrNames = [[NSMutableArray alloc] initWithCapacity:[_sections count]];
    for ( NSDictionary * dic in _sections )
    {
        [arrNames addObject:[dic objectForKey:@"name"]];
    }
    return arrNames;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ( _sections != nil && index < [_sections count] )
    {
        return index;
    }
    return 0;
}



#pragma mark <EditableTableViewCellDelegate> Methods and editing management

- (BOOL)cellShouldBeginEditing:(EditableTableViewCell *)cell
{
    /* notify other cells to end editing
	 if (![cell isEqual:newWordCell])
	 [newWordCell stopEditing];
	 */
	
    return [self.tableView isEditing];
}

- (void)cellDidEndEditing:(EditableTableViewCell *)cell
{
}

- (void)keyboardWillShow:(NSNotification *)notif
{
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


@end
