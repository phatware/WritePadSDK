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
        
        self.textView = WPTextView.createTextView(self.view.bounds)
        self.textView.delegate = self
        self.view.addSubview(self.textView)
        
        let suggestions : SuggestionsView = SuggestionsView.shared()
        suggestions.showResultsinKeyboard(self.view, in:self.view.bounds)
        suggestions.translatesAutoresizingMaskIntoConstraints = false
        suggestions.backgroundColor = UIColor( white: 0.22, alpha:0.92)
        
        self.suggestionsHeight = NSLayoutConstraint( item:suggestions,
            attribute: NSLayoutAttribute.height,
            relatedBy: NSLayoutRelation.equal, toItem: nil,
            attribute: NSLayoutAttribute.height,
            multiplier: 1.0, constant: SuggestionsView.getHeight())
        suggestions.addConstraint( self.suggestionsHeight )
        
        let leftS = NSLayoutConstraint( item:suggestions,
            attribute: NSLayoutAttribute.left,
            relatedBy: NSLayoutRelation.equal, toItem:self.view,
            attribute: NSLayoutAttribute.left,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( leftS )
        let topS = NSLayoutConstraint( item:suggestions,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal, toItem:self.navBar,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( topS )
        let rightS = NSLayoutConstraint( item:suggestions,
            attribute: NSLayoutAttribute.right,
            relatedBy: NSLayoutRelation.equal, toItem:self.view,
            attribute: NSLayoutAttribute.right,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( rightS )
        
        let right = NSLayoutConstraint( item: self.textView,
            attribute: NSLayoutAttribute.right,
            relatedBy: NSLayoutRelation.equal, toItem:self.view,
            attribute: NSLayoutAttribute.right,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( right )
        let left = NSLayoutConstraint( item: self.textView,
            attribute: NSLayoutAttribute.left,
            relatedBy: NSLayoutRelation.equal, toItem:self.view,
            attribute: NSLayoutAttribute.left,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( left )
        let top = NSLayoutConstraint( item: self.textView,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal, toItem: suggestions,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( top )
        
        self.keyboardHeight = NSLayoutConstraint( item: self.textView,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal, toItem: self.view,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1.0, constant: 0.0 )
        self.view.addConstraint( self.keyboardHeight )
        
        let notifications = NotificationCenter.default
        notifications.addObserver( self, selector:#selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notifications.addObserver( self, selector:#selector(ViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        notifications.addObserver( self, selector:#selector(ViewController.keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        notifications.addObserver( self, selector:#selector(ViewController.reloadOptions(_:)), name: NSNotification.Name(rawValue: EDITCTL_RELOAD_OPTIONS), object: nil)
        
        let defaults = UserDefaults.standard
        let language = UInt32( defaults.integer( forKey: kGeneralOptionsCurrentLanguage ) )
        if (language < WPLanguageEnglishUS.rawValue) || (language > WPLanguageMedicalUK.rawValue)
        {
            let time : DispatchTime = DispatchTime.now() + Double(Int64(0.8 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter( deadline: time, execute: { () -> Void in
                self.selectDefaultLanguage()
                // your function here
            })
        }
        
        let path = Bundle.main.path(forResource: "ReleaseNotes", ofType: "txt")
        let text = try! String(contentsOfFile: path!, encoding: String.Encoding.utf8)
        
        self.textView.text = text
        self.input.selectedSegmentIndex = Int( InputSystem_InputPanel.rawValue )
        self.textView.setInputMethod(InputSystem_InputPanel)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func selectDefaultLanguage()
    {
        let langman = LanguageManager.shared()
        let viewController = LanguageViewController( style: UITableViewStyle.plain )
        viewController.delegate = self
        
        let navigationContoller = UINavigationController(rootViewController: viewController)
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.formSheet
        navigationContoller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        let languages : NSArray = langman!.supportedLanguages() as NSArray
        // var arrLanguages : [[String:UIImage]] = []
        var arrLanguages : Dictionary<String,UIImage> = [String:UIImage](minimumCapacity: languages.count)

        for l in languages
        {
            let lang : WPLanguage = langman!.languageID(fromLanguageCode:(l as! Int32))
            arrLanguages.updateValue((langman?.languageImage(forLanguageID: lang))!,
                forKey: (langman?.languageName(lang))!)
            if langman?.currentLanguage.rawValue == lang.rawValue
            {
                viewController.selectedLanguage = langman?.languageName(lang)
            }
        }
        viewController.languages = arrLanguages
        viewController.showDone = true
        self.present( navigationContoller, animated: true ) { () -> Void in
            
        }
    }
    
    func languageSelected( _ language : String )
    {
        let recognizer = RecognizerManager.shared()
        let mode = recognizer?.getMode()
        recognizer?.disable( true )
        let langman = LanguageManager.shared()
        let languages : NSArray = langman!.supportedLanguages() as NSArray
        for l in languages
        {
            let lang : WPLanguage = langman!.languageID(fromLanguageCode:(l as! Int32))
            if language == langman?.languageName(lang)
            {
                UserDefaults.standard.set(Int(lang.rawValue), forKey: kGeneralOptionsCurrentLanguage)
            }
        }
        recognizer?.enable()
        recognizer?.setMode( mode! )
        textView.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear( animated )
        textView.becomeFirstResponder()
    }
    
    @IBAction func options( _ sender: UIBarButtonItem )
    {
        let viewController = OptionsViewController( style: UITableViewStyle.grouped )
        
        let navigationContoller = UINavigationController(rootViewController: viewController)
        navigationContoller.modalPresentationStyle = UIModalPresentationStyle.formSheet
        navigationContoller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        
        self.present( navigationContoller, animated: true ) { () -> Void in
            
        }
    }
    
    @IBAction func selectInput(_ sender: UISegmentedControl)
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
        UIView.animate( withDuration: 0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        } ) 
    }
    
    @objc func reloadOptions( _ notification: Notification )
    {
        let recognizer = RecognizerManager.shared()
        let mode = recognizer?.getMode()
        recognizer?.disable( true )
        recognizer?.enable()
        recognizer?.setMode( mode! )
        self.textView.reloadOptions()
        textView.becomeFirstResponder()
    }
    
    @objc func keyboardWillShow(_ notification: Notification)
    {
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let kbFrame : NSValue = info.object( forKey: UIKeyboardFrameEndUserInfoKey ) as! NSValue
        let animationDuration : NSNumber = info.object( forKey: UIKeyboardAnimationDurationUserInfoKey ) as! NSNumber
        let keyboardFrame : CGRect = kbFrame.cgRectValue
        let duration : TimeInterval = animationDuration.doubleValue
        
        let height = keyboardFrame.size.height
        self.keyboardHeight.constant = -height;
        
        self.view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    

    @objc func keyboardWillHide(_ notification: Notification)
    {
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let animationDuration : NSNumber = info.object( forKey: UIKeyboardAnimationDurationUserInfoKey ) as! NSNumber
        let duration : TimeInterval = animationDuration.doubleValue
        
        self.keyboardHeight.constant = 0;
        self.view.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) 
    }
    
    @objc func keyboardDidShow(_ notification: Notification)
    {
        textView.scrollToVisible()
    }

    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
    {
        // textView.becomeFirstResponder()
        return true
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver( self )
    }
}

