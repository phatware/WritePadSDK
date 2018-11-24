//
/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    Copyright (c) 2008-2018 PhatWare(r) Corp. All rights reserved.                 * */
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

#import "ViewController.h"
#import "UIConst.h"
#import "RecognizerManager.h"
#import "EditOptionsViewController.h"
#import "OptionKeys.h"

#define MARGIN_OFFSET   16.0

@interface ViewController ()

@property (nonatomic, strong)  WPTextView * textView;
@property (nonatomic, strong)  NSLayoutConstraint *keyboardHeight;
@property (nonatomic, strong)  NSLayoutConstraint *suggestionsHeight;

@end

@implementation ViewController

- (void) create_WPTextView
{
    WPTextView * textView = [[WPTextView alloc] initWithFrame:self.view.bounds];
    
    textView.opaque = NO;
    textView.font = [UIFont fontWithName:@"Arial" size:20.0];
    textView.backgroundColor = [UIColor clearColor];
    textView.returnKeyType = UIReturnKeyDefault;
    textView.autoresizesSubviews = YES;
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.delegate = self;
    textView.insetsLayoutMarginsFromSafeArea = YES;
    textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
    [self.view addSubview:textView];
    self.textView = textView;
    
    SuggestionsView * suggestions = [SuggestionsView sharedSuggestionsView];
    
    [suggestions showResultsinKeyboard:self.view inRect:self.view.bounds];
    suggestions.translatesAutoresizingMaskIntoConstraints = NO;

    // show suggestions view
    NSLayoutConstraint * constr;
    self.suggestionsHeight = [NSLayoutConstraint constraintWithItem:suggestions
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:[SuggestionsView getHeight]];
    [suggestions addConstraint:self.suggestionsHeight];
    constr = [NSLayoutConstraint constraintWithItem:suggestions
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self.view attribute:NSLayoutAttributeLeftMargin
                                         multiplier:1.0
                                           constant:-MARGIN_OFFSET];
    [self.view addConstraint:constr];
    constr = [NSLayoutConstraint constraintWithItem:suggestions
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self.view
                                          attribute:NSLayoutAttributeRightMargin
                                         multiplier:1.0
                                           constant:MARGIN_OFFSET];
    [self.view addConstraint:constr];
    constr = [NSLayoutConstraint constraintWithItem:suggestions
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self.navBar
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:0.0];
    [self.view addConstraint:constr];
    
    constr = [NSLayoutConstraint constraintWithItem:textView
                                          attribute:NSLayoutAttributeLeft
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self.view
                                          attribute:NSLayoutAttributeLeftMargin
                                         multiplier:1.0
                                           constant:-MARGIN_OFFSET];
    [self.view addConstraint:constr];
    constr = [NSLayoutConstraint constraintWithItem:textView
                                          attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:self.view
                                          attribute:NSLayoutAttributeRightMargin
                                         multiplier:1.0
                                           constant:MARGIN_OFFSET];
    [self.view addConstraint:constr];
    constr = [NSLayoutConstraint constraintWithItem:textView
                                          attribute:NSLayoutAttributeTop
                                          relatedBy:NSLayoutRelationEqual
                                             toItem:suggestions
                                          attribute:NSLayoutAttributeBottom
                                         multiplier:1.0
                                           constant:0.0];
    [self.view addConstraint:constr];

    // Use autolayout to position the view
    self.keyboardHeight = [NSLayoutConstraint constraintWithItem:textView
                                                       attribute:NSLayoutAttributeBottom
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:self.view
                                                       attribute:NSLayoutAttributeBottom
                                                      multiplier:1.0
                                                        constant:0.0];
    [self.view addConstraint:self.keyboardHeight];
    
    // Uncomment to show suggestion view as popup
    // [self.view addSubview:suggestions];
    suggestions.backgroundColor = [UIColor colorWithWhite:0.22 alpha:0.92];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // prompt user to specify the default languag
    NSInteger language = [[NSUserDefaults standardUserDefaults] integerForKey:kGeneralOptionsCurrentLanguage];
    if ( language < WPLanguageEnglishUS || language > WPLanguageMedicalUS )
    {
        [self performSelector:@selector(selectDefaultLanguage:) withObject:nil afterDelay:0.8];
    }

    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillHideNotification object:nil];
    
    // create WPTextView
    [self create_WPTextView];
    
    // load smaple text into the edit control:
    NSError	*	fileerror = nil;
    NSString *	fileName = [[NSString alloc] initWithString:[[NSBundle mainBundle] pathForResource:@"ReleaseNotes" ofType:@"txt"]];
    NSString *	text = [[NSString alloc] initWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:&fileerror];
    _textView.text = text;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadOptions:) name:EDITCTL_RELOAD_OPTIONS object:nil];
    
    self.input.selectedSegmentIndex = InputSystem_InputPanel;
    [_textView setInputMethod:InputSystem_InputPanel];
}

-(IBAction) onInput:(id)sender
{
    self.keyboardHeight.constant = 0.0;
    [_textView setInputMethod:(int)self.input.selectedSegmentIndex];
    self.suggestionsHeight.constant = (_textView.inputSystem == InputSystem_Keyboard) ? 0.0 : [SuggestionsView getHeight];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Make the keyboard appear when the application launches.
    [super viewWillAppear:animated];
    [_textView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // After everything has been initialized set this flag
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kRecoOptionsFirstStartKey];
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)aTextView
{
    return YES;
}

- (void) reloadOptions:(NSNotification *)notification
{
    int mode = [[RecognizerManager sharedManager] getMode];
    [[RecognizerManager sharedManager] disable:YES];
    [[RecognizerManager sharedManager] enable];
    [[RecognizerManager sharedManager] setMode:mode];
    [_textView reloadOptions];
}

- (BOOL) textViewShouldEndEditing:(UITextView *)aTextView
{
    [aTextView resignFirstResponder];
    return YES;
}

- (void)textViewDidChangeSelection:(UITextView *)aTextView
{
    // [textView hideSuggestions];
}

#pragma mark --- Handling keyboard events

- (void)keyboardWillShow:(NSNotification *)notification
{
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    NSLog(@"The keyboard height is: %f", height);
    
    self.keyboardHeight.constant = -height;
    
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.keyboardHeight.constant = 0;
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    [self.textView scrollToVisible];
}


#pragma mark --- Options and language selector

-(IBAction) onOptions:(id)sender
{
    // show default options dialog
    EditOptionsViewController *viewController = [[EditOptionsViewController alloc] initWithStyle:(UITableViewStyleGrouped)];
    viewController.showDone = YES;
    // Create the navigation controller and present it modally.
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
    
    // The navigation controller is now owned by the current view controller
    // and the root view controller is owned by the navigation controller,
    // so both objects should be released to prevent over-retention.
}

- (void) selectDefaultLanguage:(NSObject *)param
{
    LanguageManager * langman = [LanguageManager sharedManager];
    LanguageViewController *viewController = [[LanguageViewController alloc] initWithStyle:UITableViewStyleGrouped];
    NSArray * langs = [langman supportedLanguages];
    NSMutableArray * languages = [NSMutableArray arrayWithCapacity:[langs count]];
    NSInteger index = 0;
    viewController.selectedIndex = index;
    
    NSDictionary * language;
    for ( NSNumber * l in langs )
    {
        WPLanguage lang = [langman languageIDFromLanguageCode:[l intValue]];
        UIImage * image = [langman languageImageForLanguageID:lang];
        NSString * name = [langman languageName:lang];
        language = @{ @"name" : name, @"ID" : [NSNumber numberWithInt:lang], @"image" : image };
        [languages addObject:language];
        index++;
    }
    viewController.languages = [NSArray arrayWithArray:languages];
    viewController.delegate = self;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void) languageSelected:(LanguageViewController *)viewController language:(int)language
{
    int mode = [[RecognizerManager sharedManager] getMode];
    [[RecognizerManager sharedManager] disable:YES];
    [[NSUserDefaults standardUserDefaults] setInteger:language forKey:kGeneralOptionsCurrentLanguage];
    [[RecognizerManager sharedManager] enable];
    [[RecognizerManager sharedManager] setMode:mode];
}


#pragma mark --

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    self.keyboardHeight = nil;
    self.suggestionsHeight = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_textView removeFromSuperview];
    self.textView = nil;
}

@end
