/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    OptionsViewController.swift                                                    * */
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

class OptionsViewController: UITableViewController, LanguageSelectorDelegate
{
    
    enum RecognizerSettings : Int
    {
        // recognizer
        case Language_Section = 0
        case ShapeSelector_Section = 1
        case UseCorrector_Section = 2
        case UseUserDict_Section = 3
        case UseLearner_Section = 4
        case DetectNewLine_Section = 5
        case Autospace_Section = 6
        case SeparateLetters_Section = 7
        case SingleWord_Section = 8
        // dictionary
        case OnlyDictWords_Section = 9
        // ink Collector
        case InsertResult_Section = 10
        // total
        case Total_Sections = 11
    };


    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.title = "Options"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "DoneButton:")
    }
    
    func createSwitch( on : Bool, tag: Int ) -> UISwitch
    {
        let sw : UISwitch = UISwitch()
        sw.addTarget(self, action: "switchAction:", forControlEvents: UIControlEvents.ValueChanged )
        sw.on = on;
        sw.tag = tag;
        return sw
    }

    @objc func DoneButton( sender : UIBarButtonItem )
    {
        self.dismissViewControllerAnimated( true, completion: { () -> Void in
            let notifications = NSNotificationCenter.defaultCenter()
            notifications.postNotificationName(EDITCTL_RELOAD_OPTIONS, object: nil)
        })
    }

    @objc func switchAction( sender : UISwitch )
    {
        let def = NSUserDefaults.standardUserDefaults()
        
        switch sender.tag
        {
            case RecognizerSettings.UseLearner_Section.rawValue :
                def.setBool(sender.on, forKey: kRecoOptionsUseLearner)
            
            case RecognizerSettings.UseCorrector_Section.rawValue :
                def.setBool(sender.on, forKey: kRecoOptionsUseCorrector)
            
            case RecognizerSettings.DetectNewLine_Section.rawValue :
                def.setBool(sender.on, forKey: kRecoOptionsDetectNewLine)
            
            case RecognizerSettings.Autospace_Section.rawValue :
                def.setBool(sender.on, forKey: kEditOptionsAutospace)
            
            case RecognizerSettings.SeparateLetters_Section.rawValue :
                def.setBool(sender.on, forKey: kRecoOptionsSeparateLetters)
            
            case RecognizerSettings.OnlyDictWords_Section.rawValue  :
                def.setBool(sender.on, forKey: kRecoOptionsDictOnly)
            
            case RecognizerSettings.UseUserDict_Section.rawValue :
                def.setBool(sender.on, forKey: kRecoOptionsUseUserDict)
            
            case RecognizerSettings.InsertResult_Section.rawValue :
                def.setBool(sender.on, forKey: kRecoOptionsInsertResult)
            
            case RecognizerSettings.SingleWord_Section.rawValue :
                def.setBool(sender.on, forKey: kRecoOptionsSingleWordOnly)
            
            default :
                break
        }

    }
    
    func letterShapes()
    {
        let viewController = LetterShapesController()
        self.navigationController!.pushViewController(viewController, animated: true )
    }
    
    func userDictionary()
    {
        let viewController = UserDictViewController()
        self.navigationController!.pushViewController(viewController, animated: true )
    }

    func wordList()
    {
        let viewController = WordListViewController()
        self.navigationController!.pushViewController(viewController, animated: true )
    }
    
    func selectLanguage()
    {
        let langman = LanguageManager.sharedManager()
        let viewController = LanguageViewController( style: UITableViewStyle.Plain )
        viewController.delegate = self
        
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
        self.navigationController!.pushViewController(viewController, animated: true )
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
        self.tableView.reloadData()
    }


    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return RecognizerSettings.Total_Sections.rawValue
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == RecognizerSettings.UseUserDict_Section.rawValue ||
            section == RecognizerSettings.UseCorrector_Section.rawValue)
        {
            return 2
        }
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("ID1092868641") as UITableViewCell?
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ID1092868641")
        }
        
        // Configure the cell...
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.accessoryType = UITableViewCellAccessoryType.None
        
        let def = NSUserDefaults.standardUserDefaults()
        
        switch indexPath.section
        {
            case RecognizerSettings.ShapeSelector_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = nil
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.Default
                cell!.textLabel!.text = "Letter Shapes"

            case RecognizerSettings.Language_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = nil
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.Default
                cell!.textLabel!.text = "Language: " + LanguageManager.sharedManager().languageName(WPLanguageUnknown)
            
            case RecognizerSettings.UseLearner_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.boolForKey(kRecoOptionsUseLearner) , tag: indexPath.section )
                cell!.textLabel!.text = "Use Learner"
            
            case RecognizerSettings.UseCorrector_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.boolForKey(kRecoOptionsUseCorrector) , tag: indexPath.section )
                cell!.textLabel!.text = "Autocorrector"
            
            case RecognizerSettings.UseCorrector_Section.rawValue where indexPath.row == 1 :
                cell!.accessoryView = nil
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.Default
                cell!.textLabel!.text = "Autocorrector Word List"

            case RecognizerSettings.DetectNewLine_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.boolForKey(kRecoOptionsDetectNewLine) , tag: indexPath.section )
                cell!.textLabel!.text = "Detect New Line"
            
            case RecognizerSettings.Autospace_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.boolForKey(kEditOptionsAutospace) , tag: indexPath.section )
                cell!.textLabel!.text = "Add Space"
            
            case RecognizerSettings.SeparateLetters_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.boolForKey(kRecoOptionsSeparateLetters) , tag: indexPath.section )
                cell!.textLabel!.text = "Separate Letters"
            
            case RecognizerSettings.OnlyDictWords_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.boolForKey(kRecoOptionsDictOnly) , tag: indexPath.section )
                cell!.textLabel!.text = "Separate Letters"
            
            case RecognizerSettings.UseUserDict_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.boolForKey(kRecoOptionsUseUserDict) , tag: indexPath.section )
                cell!.textLabel!.text = "User Dictionary"
            
            case RecognizerSettings.UseUserDict_Section.rawValue where indexPath.row == 1 :
                cell!.accessoryView = nil
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.Default
                cell!.textLabel!.text = "Edit User Dictionary"

            case RecognizerSettings.InsertResult_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.boolForKey(kRecoOptionsInsertResult) , tag: indexPath.section )
                cell!.textLabel!.text = "Continuous Writing"
            
            case RecognizerSettings.SingleWord_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.boolForKey(kRecoOptionsSingleWordOnly) , tag: indexPath.section )
                cell!.textLabel!.text = "Single Word Only"
            
            default :
                break
        }

        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        switch indexPath.section
        {
            case RecognizerSettings.ShapeSelector_Section.rawValue where indexPath.row == 0 :
                letterShapes()
            
            case RecognizerSettings.Language_Section.rawValue where indexPath.row == 0 :
                selectLanguage()

            case RecognizerSettings.UseUserDict_Section.rawValue where indexPath.row == 1 :
                userDictionary()
            
            case RecognizerSettings.UseCorrector_Section.rawValue where indexPath.row == 1 :
                wordList()
                
            default :
                break
        }
        tableView.deselectRowAtIndexPath( indexPath, animated: true)
    }
}