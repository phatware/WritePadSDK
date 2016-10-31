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
        case language_Section = 0
        case shapeSelector_Section = 1
        case useCorrector_Section = 2
        case useUserDict_Section = 3
        case useLearner_Section = 4
        case detectNewLine_Section = 5
        case autospace_Section = 6
        case separateLetters_Section = 7
        case singleWord_Section = 8
        // dictionary
        case onlyDictWords_Section = 9
        // ink Collector
        case insertResult_Section = 10
        // total
        case total_Sections = 11
    };


    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.title = "Options"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(OptionsViewController.DoneButton(_:)))
    }
    
    func createSwitch( _ on : Bool, tag: Int ) -> UISwitch
    {
        let sw : UISwitch = UISwitch()
        sw.addTarget(self, action: #selector(OptionsViewController.switchAction(_:)), for: UIControlEvents.valueChanged )
        sw.isOn = on;
        sw.tag = tag;
        return sw
    }

    @objc func DoneButton( _ sender : UIBarButtonItem )
    {
        self.dismiss( animated: true, completion: { () -> Void in
            let notifications = NotificationCenter.default
            notifications.post(name: Notification.Name(rawValue: EDITCTL_RELOAD_OPTIONS), object: nil)
        })
    }

    @objc func switchAction( _ sender : UISwitch )
    {
        let def = UserDefaults.standard
        
        switch sender.tag
        {
            case RecognizerSettings.useLearner_Section.rawValue :
                def.set(sender.isOn, forKey: kRecoOptionsUseLearner)
            
            case RecognizerSettings.useCorrector_Section.rawValue :
                def.set(sender.isOn, forKey: kRecoOptionsUseCorrector)
            
            case RecognizerSettings.detectNewLine_Section.rawValue :
                def.set(sender.isOn, forKey: kRecoOptionsDetectNewLine)
            
            case RecognizerSettings.autospace_Section.rawValue :
                def.set(sender.isOn, forKey: kEditOptionsAutospace)
            
            case RecognizerSettings.separateLetters_Section.rawValue :
                def.set(sender.isOn, forKey: kRecoOptionsSeparateLetters)
            
            case RecognizerSettings.onlyDictWords_Section.rawValue  :
                def.set(sender.isOn, forKey: kRecoOptionsDictOnly)
            
            case RecognizerSettings.useUserDict_Section.rawValue :
                def.set(sender.isOn, forKey: kRecoOptionsUseUserDict)
            
            case RecognizerSettings.insertResult_Section.rawValue :
                def.set(sender.isOn, forKey: kRecoOptionsInsertResult)
            
            case RecognizerSettings.singleWord_Section.rawValue :
                def.set(sender.isOn, forKey: kRecoOptionsSingleWordOnly)
            
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
        let langman = LanguageManager.shared()
        let viewController = LanguageViewController( style: UITableViewStyle.plain )
        viewController.delegate = self
        
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
        self.navigationController!.pushViewController(viewController, animated: true )
    }
    
    func languageSelected( _ language : String )
    {
        let recognizer = RecognizerManager.shared()
        let mode = recognizer?.getMode()
        recognizer?.disable( true )
        let langman : LanguageManager = LanguageManager.shared()
        let languages : NSArray = langman.supportedLanguages() as NSArray
        for l in languages
        {
            let lang : WPLanguage = langman.languageID(fromLanguageCode:(l as! Int32))
            if language == langman.languageName(lang)
            {
                UserDefaults.standard.set(Int(lang.rawValue), forKey: kGeneralOptionsCurrentLanguage)
            }
        }
        recognizer?.enable()
        recognizer?.setMode( mode! )
        self.tableView.reloadData()
    }


    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return RecognizerSettings.total_Sections.rawValue
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == RecognizerSettings.useUserDict_Section.rawValue ||
            section == RecognizerSettings.useCorrector_Section.rawValue)
        {
            return 2
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "ID1092868641") as UITableViewCell?
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ID1092868641")
        }
        
        // Configure the cell...
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        cell!.accessoryType = UITableViewCellAccessoryType.none
        
        let def = UserDefaults.standard
        
        switch indexPath.section
        {
            case RecognizerSettings.shapeSelector_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = nil
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.default
                cell!.textLabel!.text = "Letter Shapes"

            case RecognizerSettings.language_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = nil
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.default
                cell!.textLabel!.text = "Language: " + LanguageManager.shared().languageName(WPLanguageUnknown)
            
            case RecognizerSettings.useLearner_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.bool(forKey: kRecoOptionsUseLearner) , tag: indexPath.section )
                cell!.textLabel!.text = "Use Learner"
            
            case RecognizerSettings.useCorrector_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.bool(forKey: kRecoOptionsUseCorrector) , tag: indexPath.section )
                cell!.textLabel!.text = "Autocorrector"
            
            case RecognizerSettings.useCorrector_Section.rawValue where indexPath.row == 1 :
                cell!.accessoryView = nil
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.default
                cell!.textLabel!.text = "Autocorrector Word List"

            case RecognizerSettings.detectNewLine_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.bool(forKey: kRecoOptionsDetectNewLine) , tag: indexPath.section )
                cell!.textLabel!.text = "Detect New Line"
            
            case RecognizerSettings.autospace_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.bool(forKey: kEditOptionsAutospace) , tag: indexPath.section )
                cell!.textLabel!.text = "Add Space"
            
            case RecognizerSettings.separateLetters_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.bool(forKey: kRecoOptionsSeparateLetters) , tag: indexPath.section )
                cell!.textLabel!.text = "Separate Letters"
            
            case RecognizerSettings.onlyDictWords_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.bool(forKey: kRecoOptionsDictOnly) , tag: indexPath.section )
                cell!.textLabel!.text = "Separate Letters"
            
            case RecognizerSettings.useUserDict_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.bool(forKey: kRecoOptionsUseUserDict) , tag: indexPath.section )
                cell!.textLabel!.text = "User Dictionary"
            
            case RecognizerSettings.useUserDict_Section.rawValue where indexPath.row == 1 :
                cell!.accessoryView = nil
                cell!.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                cell!.selectionStyle = UITableViewCellSelectionStyle.default
                cell!.textLabel!.text = "Edit User Dictionary"

            case RecognizerSettings.insertResult_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.bool(forKey: kRecoOptionsInsertResult) , tag: indexPath.section )
                cell!.textLabel!.text = "Continuous Writing"
            
            case RecognizerSettings.singleWord_Section.rawValue where indexPath.row == 0 :
                cell!.accessoryView = createSwitch( def.bool(forKey: kRecoOptionsSingleWordOnly) , tag: indexPath.section )
                cell!.textLabel!.text = "Single Word Only"
            
            default :
                break
        }

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.section
        {
            case RecognizerSettings.shapeSelector_Section.rawValue where indexPath.row == 0 :
                letterShapes()
            
            case RecognizerSettings.language_Section.rawValue where indexPath.row == 0 :
                selectLanguage()

            case RecognizerSettings.useUserDict_Section.rawValue where indexPath.row == 1 :
                userDictionary()
            
            case RecognizerSettings.useCorrector_Section.rawValue where indexPath.row == 1 :
                wordList()
                
            default :
                break
        }
        tableView.deselectRow( at: indexPath, animated: true)
    }
}
