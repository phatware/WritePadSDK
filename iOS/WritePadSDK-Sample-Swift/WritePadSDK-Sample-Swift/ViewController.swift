/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    ViewController.swift                                                           * */
/* *    Created by Stanislav Miasnikov on 4/19/15                                      * */
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

import UIKit

func == ( left: InputSystem, right: InputSystem ) -> Bool
{
    return left.rawValue == right.rawValue
}

class ViewController: UIViewController, UITextViewDelegate, LanguageSelectorDelegate
{
    @IBOutlet var input  : UISegmentedControl!
    @IBOutlet var navBar : UINavigationBar!
    
    var textView : WPTextView!
    var suggestionsHeight : NSLayoutConstraint!
    var keyboardHeight : NSLayoutConstraint!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.textView = WPTextViewCreate( self.view.frame )
        self.textView.delegate = self
        self.view.addSubview(self.textView)
        
        let suggestions = SuggestionsView.sharedSuggestionsView()
        suggestions.showResultsinKeyboard(self.view, inRect:self.view.bounds)
        suggestions.translatesAutoresizingMaskIntoConstraints = false
        suggestions.backgroundColor = UIColor( white: 0.22, alpha:0.92)
        
        self.suggestionsHeight = NSLayoutConstraint( item:suggestions,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal, toItem: nil,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1.0, constant: SuggestionsView.getHeight())
        suggestions.addConstraint( self.suggestionsHeight )
        
        let leftS = NSLayoutConstraint( item:suggestions,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal, toItem:self.view,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( leftS )
        let topS = NSLayoutConstraint( item:suggestions,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal, toItem:self.navBar,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( topS )
        let rightS = NSLayoutConstraint( item:suggestions,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal, toItem:self.view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( rightS )
        
        let right = NSLayoutConstraint( item: self.textView,
            attribute: NSLayoutAttribute.Right,
            relatedBy: NSLayoutRelation.Equal, toItem:self.view,
            attribute: NSLayoutAttribute.Right,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( right )
        let left = NSLayoutConstraint( item: self.textView,
            attribute: NSLayoutAttribute.Left,
            relatedBy: NSLayoutRelation.Equal, toItem:self.view,
            attribute: NSLayoutAttribute.Left,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( left )
        let top = NSLayoutConstraint( item: self.textView,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal, toItem: suggestions,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( top )
        
        self.keyboardHeight = NSLayoutConstraint( item: self.textView,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal, toItem: self.view,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( self.keyboardHeight )
        
        let notifications = NSNotificationCenter.defaultCenter()
        notifications.addObserver( self, selector:"keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        notifications.addObserver( self, selector:"keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        notifications.addObserver( self, selector:"keyboardDidShow:", name: UIKeyboardDidShowNotification, object: nil)
        notifications.addObserver( self, selector:"reloadOptions:", name: EDITCTL_RELOAD_OPTIONS, object: nil)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let language = UInt32( defaults.integerForKey( kGeneralOptionsCurrentLanguage ) )
        if (language < WPLanguageEnglishUS.rawValue) || (language > WPLanguageMedicalUK.rawValue)
        {
            let time : dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC)))
            dispatch_after( time, dispatch_get_main_queue(), { () -> Void in
                self.selectDefaultLanguage()
                // your function here
            })
        }
        
        let path = NSBundle.mainBundle().pathForResource("ReleaseNotes", ofType: "txt")
        let text = try! String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
        
        self.textView.text = text
        self.input.selectedSegmentIndex = Int( InputSystem_InputPanel.rawValue )
        self.textView.setInputMethod(InputSystem_InputPanel)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func selectDefaultLanguage()
    {
        let langman = LanguageManager.sharedManager()
        let viewController = LanguageViewController( style: UITableViewStyle.Plain )
        viewController.delegate = self
        
        let navigationContoller = UINavigationController(rootViewController: viewController)
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        navigationContoller.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        let languages : NSArray = langman.supportedLanguages()
        // var arrLanguages : [[String:UIImage]] = []
        var arrLanguages : Dictionary<String,UIImage> = [String:UIImage](minimumCapacity: languages.count)

        for l in languages
        {
            let lang : WPLanguage = langman.languageFromLanguageID(Int32(l.integerValue))
            arrLanguages.updateValue(langman.languageImageForLanguageID(lang),
                forKey: langman.languageName(lang))
            if langman.currentLanguage.rawValue == lang.rawValue
            {
                viewController.selectedLanguage = langman.languageName(lang)
            }
        }
        viewController.languages = arrLanguages
        viewController.showDone = true
        self.presentViewController( navigationContoller, animated: true ) { () -> Void in
            
        }
    }
    
    func languageSelected( language : String )
    {
        let recognizer = RecognizerManager.sharedManager()
        let mode = recognizer.getMode()
        recognizer.disable( true )
        let langman = LanguageManager.sharedManager()
        let languages : NSArray = langman.supportedLanguages()
        for l in languages
        {
            let lang : WPLanguage = langman.languageFromLanguageID(Int32(l.integerValue))
            if language == langman.languageName(lang)
            {
                NSUserDefaults.standardUserDefaults().setInteger(Int(lang.rawValue), forKey: kGeneralOptionsCurrentLanguage)
            }
        }
        recognizer.enable()
        recognizer.setMode( mode )
        textView.becomeFirstResponder()
    }
    
    override func viewDidAppear(animated: Bool)
    {
        super.viewDidAppear( animated )
        textView.becomeFirstResponder()
    }
    
    @IBAction func options( sender: UIBarButtonItem )
    {
        let viewController = OptionsViewController( style: UITableViewStyle.Grouped )
        
        let navigationContoller = UINavigationController(rootViewController: viewController)
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        navigationContoller.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        
        self.presentViewController( navigationContoller, animated: true ) { () -> Void in
            
        }
    }
    
    @IBAction func selectInput(sender: UISegmentedControl)
    {
        var inputSystem : InputSystem = InputSystem_InputPanel;
        switch self.input.selectedSegmentIndex
        {
            case 1 :
                inputSystem = InputSystem_WriteAnywhere
                break
            case 2 :
                inputSystem = InputSystem_Keyboard
                break
            default :
                inputSystem = InputSystem_InputPanel
        }
        self.textView.setInputMethod(inputSystem)
        self.suggestionsHeight.constant = (inputSystem == InputSystem_Keyboard) ? 0.0 : SuggestionsView.getHeight()
        UIView.animateWithDuration( 0.3 ) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func reloadOptions( notification: NSNotification )
    {
        let recognizer = RecognizerManager.sharedManager()
        let mode = recognizer.getMode()
        recognizer.disable( true )
        recognizer.enable()
        recognizer.setMode( mode )
        self.textView.reloadOptions()
        textView.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        let info : NSDictionary = notification.userInfo!
        let kbFrame : NSValue = info.objectForKey( UIKeyboardFrameEndUserInfoKey ) as! NSValue
        let animationDuration : NSNumber = info.objectForKey( UIKeyboardAnimationDurationUserInfoKey ) as! NSNumber
        let keyboardFrame : CGRect = kbFrame.CGRectValue()
        let duration : NSTimeInterval = animationDuration.doubleValue
        
        let height = keyboardFrame.size.height
        self.keyboardHeight.constant = -height;
        
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(duration) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    

    @objc func keyboardWillHide(notification: NSNotification)
    {
        let info : NSDictionary = notification.userInfo!
        let animationDuration : NSNumber = info.objectForKey( UIKeyboardAnimationDurationUserInfoKey ) as! NSNumber
        let duration : NSTimeInterval = animationDuration.doubleValue
        
        self.keyboardHeight.constant = 0;
        self.view.setNeedsUpdateConstraints()
        
        UIView.animateWithDuration(duration) { () -> Void in
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDidShow(notification: NSNotification)
    {
        textView.scrollToVisible()
    }

    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        // textView.becomeFirstResponder()
        return true
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver( self )
    }
}

