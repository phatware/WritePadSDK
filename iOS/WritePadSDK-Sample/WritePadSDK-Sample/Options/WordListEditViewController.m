/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2015 PhatWare(r) Corp. All rights reserved.                 * */
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

#import "WordListEditViewController.h"
#import "EditWordViewController.h"
#import "UIConst.h"
#import "RecognizerManager.h"

#import "WordListEditViewController.h"
#import "EditWordViewController.h"
#import "UIConst.h"
#import "utils.h"
#import "RecognizerManager.h"

static NSString *kCellIdentifier = @"WordCellIdentifier";

static int EnumWordListCallback( const UCHR * pszWordFrom, const UCHR * pszWordTo, unsigned int flags, void * pParam )
{
    NSMutableArray * array = (__bridge NSMutableArray *)pParam;
    WordListItem *	 item = [[WordListItem alloc] init];
    item.wordFrom = [RecognizerManager stringFromUchr:pszWordFrom];
    item.wordTo = [RecognizerManager stringFromUchr:pszWordTo];
    item.flags = flags;
    
    [array addObject:item];
    return 1;
}

@implementation WordListItem

@synthesize wordFrom;
@synthesize wordTo;
@synthesize flags;

- (id)init
{
    self = [super init];
    if (self)
    {
        wordFrom = nil;
        wordTo = nil;
        flags = 0;
    }
    return self;
}

@end

@interface WordListEditViewController (WordListEditViewControllerDelegate)  <EditWordViewControllerDelegate>
- (void) editWordViewController:(EditWordViewController *)wordView wordModified:(WordListItem *)item isNew:(BOOL)bNew;
@end

@implementation WordListEditViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        // this title will appear in the navigation bar
        self.title = NSLocalizedString( @"Autocorrector", @"" );
        _recognizer = [[RecognizerManager sharedManager] recognizer];
        _userWords = [[NSMutableArray alloc] init];
        _bModified = NO;
    }
    return self;
}

- (void)editWordViewController:(EditWordViewController *)wordView wordModified:(WordListItem *)item isNew:(BOOL)bNew
{
    if ( bNew && item != nil )
    {
        // add new word
        [_userWords insertObject:item atIndex:0];
        [self recalcSections];
        _bModified = YES;
    }
    else if ( item != nil )
    {
        _bModified = YES;
    }
}

static NSInteger compareUserWords (id a, id b, void *ctx )
{
    WordListItem * item1 = (WordListItem *)a;
    WordListItem * item2 = (WordListItem *)b;
    return [item1.wordFrom caseInsensitiveCompare:item2.wordFrom];
}

#pragma mark Initialize View

- (void)loadView
{
    [super loadView];
    
    buttonItemEdit = [[UIBarButtonItem alloc]
                      initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction)];
    buttonItemDone = [[UIBarButtonItem alloc]
                      initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    
    self.tableView.allowsSelectionDuringEditing = YES;
    self.tableView.autoresizesSubviews = YES;
    self.tableView.editing = NO;
   
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    _sections = [[NSMutableArray alloc ] init];
    [_userWords removeAllObjects];
    if ( _recognizer != NULL )
    {
        // enumirate user dictionary and add words to array
        int     nWords = HWR_EnumWordList( _recognizer, EnumWordListCallback, ( __bridge void *)_userWords );
        NSLog(@"%i words added", nWords );
        if ( nWords > 1 )
        {
            [_userWords sortUsingFunction:compareUserWords context:(__bridge void *)self];
        }
    }
    _bModified = NO;
}

- (IBAction)editAction
{
    if ( _recognizer != NULL )
    {
        [_sections insertObject:@{ @"name"   : @"+",
                                   @"index"  : [NSNumber numberWithInt:0],
                                   @"length" : [NSNumber numberWithInt:1] } atIndex:0];
        self.navigationItem.rightBarButtonItem = buttonItemDone;
        [self.tableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView setEditing:YES animated:YES];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:NO];
    }
}

- (IBAction)doneAction
{
    if ( _recognizer != NULL )
    {
        [self.tableView setEditing:NO animated:YES];
        self.navigationItem.rightBarButtonItem = buttonItemEdit;
        [_sections removeObjectAtIndex:0];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationTop];
        // [tableWordList reloadData];
    }
}

- (void) recalcSections
{
    [_sections removeAllObjects];
    if ( [self.tableView isEditing] )
    {
        [_sections insertObject:@{ @"name"   : @"+",
                                   @"index"  : [NSNumber numberWithInt:0],
                                   @"length" : [NSNumber numberWithInt:1] } atIndex:0];
    }
    if ( [_userWords count] < 1 )
        return;
    
    unichar chr, ch0 = [[[_userWords objectAtIndex:0] wordFrom] characterAtIndex:0];
    int index0 = 0;
    // create sections for indexing
    for ( int i = 1; i < [_userWords count]; i++ )
    {
        WordListItem * item = [_userWords objectAtIndex:i];
        chr = [item.wordFrom characterAtIndex:0];
        if ( tolower( chr ) != tolower( ch0 ) )
        {
            [_sections addObject:@{ @"name"   : [NSString stringWithCharacters:&ch0 length:1],
                                    @"index"  : [NSNumber numberWithInt:index0],
                                    @"length" : [NSNumber numberWithInt:i-index0] }];
            index0 = i;
            ch0 = chr;
        }
    }
    if ( index0 < [_userWords count] )
    {
        [_sections addObject:@{ @"name"   : [NSString stringWithCharacters:&ch0 length:1],
                                @"index"  : [NSNumber numberWithInt:index0],
                                @"length" : [NSNumber numberWithInt:(int)[_userWords count]-index0] }];
    }
}

#pragma mark UIViewController delegate methods

// called after this controller's view was dismissed, covered or otherwise hidden
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ( _bModified && _recognizer )
    {
        // save autocorrector word list
        if ( HWR_EmptyWordList( _recognizer ) )
        {
            for ( int i = 0; i < [_userWords count]; i++ )
            {
                WordListItem *	 item = [_userWords objectAtIndex:i];
                const UCHR * pszWord1 = [RecognizerManager uchrFromString:item.wordFrom];
                const UCHR * pszWord2 = [RecognizerManager uchrFromString:item.wordTo];
                HWR_AddWordToWordList( _recognizer, pszWord1, pszWord2, (int)item.flags, NO );
            }
        }
        // save the word list now
        [[RecognizerManager sharedManager] saveRecognizerDataOfType:USERDATA_AUTOCORRECTOR];
        _bModified = NO;
    }
}

// called after this controller's view will appear
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self recalcSections];
    [self.tableView reloadData];
    
    if ( _recognizer != NULL )
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
    int nRes = 0;
    if ( section  < [_sections count] )
    {
        nRes = [[[_sections objectAtIndex:section] objectForKey:@"length"] intValue];
    }
    return nRes;
}

// to determine specific row height for each cell, override this.  In this example, each row is determined
// buy the its subviews that are embedded.
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat result = kWordCellHeight;
    return result;
}


// to determine which UITableViewCell to be used on a given row.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    UITableViewCell *cell = nil;
    
    
    cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if ( cell == nil )
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = @"";
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    
    if ( [tableView isEditing] && section == 0 )
    {
        cell.textLabel.text = NSLocalizedString( @"<new word correction>", @"" );
        cell.textLabel.textColor = [UIColor grayColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    else if ( section < [_sections count] )
    {
        NSInteger index = [[[_sections objectAtIndex:section] objectForKey:@"index"] intValue] + row;
        if ( index < [_userWords count] )
        {
            WordListItem * item = [_userWords objectAtIndex:index];
            cell.textLabel.text = [NSString stringWithFormat:@"%@  =>  %@", item.wordFrom, item.wordTo];
        }
        else
        {
            NSLog( @"Error: index >= [_userWords count]" );
        }
    }
    else
    {
        NSLog( @"Error:  section >= [_sections count]" );
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath row];
    NSInteger section = [indexPath section];
    
    NSInteger index = [[[_sections objectAtIndex:section] objectForKey:@"index"] intValue] + row;
    if ( index < (int)[_userWords count] )
    {
        EditWordViewController *viewController = [[EditWordViewController alloc] initWithStyle:(UITableViewStyleGrouped)];
        
        if ( [tableView isEditing] && section == 0 )
        {
            viewController.wordListItem = nil;
        }
        else
        {
            viewController.wordListItem = [_userWords objectAtIndex:index];
        }
        viewController.delegate = self;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [tableView isEditing] )
    {
        if ( indexPath.section == 0 )
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
        NSInteger index = [[[_sections objectAtIndex:indexPath.section] objectForKey:@"index"] intValue] + indexPath.row;
        if (editingStyle == UITableViewCellEditingStyleDelete)
        {
            [_userWords removeObjectAtIndex:index];
            NSInteger sections = [_sections count];
            [self recalcSections];
            if ( sections > [_sections count] )
                [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
            else
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            _bModified = YES;
        }
        else if (editingStyle == UITableViewCellEditingStyleInsert)
        {
            EditWordViewController *viewController = [[EditWordViewController alloc] init];
            viewController.wordListItem = nil;
            viewController.delegate = self;
            [self.navigationController pushViewController:viewController animated:YES];
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

#pragma mark -


- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


@end
