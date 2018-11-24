/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    UserDictViewController.swift                                                   * */
/* *    Created by Stanislav Miasnikov on 4/19/15                                      * */
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

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class UserDictViewController: UITableViewController, UITextFieldDelegate
{
    var userWords : NSMutableArray? = nil
    var modified : Bool! = false
    var newWordField : UITextField? = nil
    let wordEditLeftOffset : CGFloat = 50.0

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.autoresizesSubviews = true
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.title = "User Dictionary"
        self.newWordField = createTextField()
    }
    
    func createTextField() -> UITextField
    {
        let frame : CGRect = CGRect(x: 0.0, y: 0.0, width: kTextFieldWidth, height: kTextFieldHeight)
        let returnTextField : UITextField = UITextField(frame: frame)
    
        returnTextField.borderStyle = UITextBorderStyle.roundedRect
        returnTextField.font = UIFont.systemFont( ofSize: 18.0 )
        returnTextField.placeholder = "Enter New Word"
        returnTextField.backgroundColor = UIColor.white
        returnTextField.autocorrectionType = UITextAutocorrectionType.no	// no auto correction support
        returnTextField.autocapitalizationType = UITextAutocapitalizationType.none
        returnTextField.autoresizingMask = UIViewAutoresizing.flexibleWidth
        returnTextField.delegate = self
        returnTextField.borderStyle = UITextBorderStyle.none
        returnTextField.keyboardType = UIKeyboardType.default
        returnTextField.returnKeyType = UIReturnKeyType.done
        returnTextField.clearButtonMode = UITextFieldViewMode.whileEditing // has a clear 'x' button to the right
    
        return returnTextField
    }
    
    func addNewWord()
    {
        if newWordField!.text!.lengthOfBytes(using: String.Encoding.utf8) > 0
        {
            newWordField!.resignFirstResponder()
            let str : String = newWordField!.text!
            let newWord = str.replacingOccurrences( of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
            if newWord.lengthOfBytes(using: String.Encoding.utf8) > 0
            {
                userWords!.insert(newWord, at: 0)
                modified = true
                tableView.reloadData()
            }
        }
        newWordField!.text = ""
    }
    
    override func setEditing(_ editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        if editing == true
        {
            tableView.insertSections( IndexSet(integer: 0), with: UITableViewRowAnimation.bottom)
            if self.newWordField != nil
            {
                newWordField!.becomeFirstResponder()
            }
        }
        else
        {
            tableView.deleteSections( IndexSet(integer: 0), with: UITableViewRowAnimation.top)
            if self.newWordField != nil
            {
                self.newWordField!.resignFirstResponder()
                addNewWord()
            }
        }
        // self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func reloadDictionary()
    {
        userWords = RecognizerManager.shared().getUserWords()!
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear( animated )
        
        self.reloadDictionary()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear( animated )
        
        if self.newWordField != nil
        {
            self.newWordField!.resignFirstResponder()
            addNewWord()
        }
        if (userWords != nil && modified == true)
        {
            RecognizerManager.shared().newUserDict( fromWordList: userWords! as [AnyObject] )
            modified = false
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return tableView.isEditing == true ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (tableView.isEditing == true && section == 0)
        {
            return 1
        }
        if userWords == nil
        {
            return 0
        }
        return userWords!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell? = nil
        if (tableView.isEditing == true && indexPath.section == 0)
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "ID1092378783") as UITableViewCell?
            if cell == nil
            {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ID1092378783")
            }
            cell!.selectionStyle = UITableViewCellSelectionStyle.none
            // newWordField!.text = "";
            cell!.contentView.autoresizesSubviews = true
            var frame = cell!.contentView.bounds
            frame.origin.x = wordEditLeftOffset
            frame.size.width -= (wordEditLeftOffset + 5)
            newWordField!.frame =  frame
            cell!.addSubview( newWordField! )
            // cell!.accessoryView = newWordField
            // cell!.textLabel!.text = "New Word"
        }
        else if indexPath.row < userWords?.count
        {
            cell = tableView.dequeueReusableCell(withIdentifier: "ID1092479864") as UITableViewCell?
            if cell == nil
            {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ID1092479864")
            }
            cell!.selectionStyle = UITableViewCellSelectionStyle.none
            cell!.accessoryType = UITableViewCellAccessoryType.none
            cell!.textLabel!.text = userWords![indexPath.row] as? String
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    {
        if ( self.tableView.isEditing == true )
        {
            if (indexPath.section == 0 )
            {
                return UITableViewCellEditingStyle.insert
            }
            return UITableViewCellEditingStyle.delete
        }
        return UITableViewCellEditingStyle.none
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        if ( tableView.isEditing == false )
        {
            return
        }
        if (editingStyle == .delete && indexPath.section == 1 && indexPath.row < userWords?.count)
        {
            // Delete the row from the data source
            userWords!.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            modified = true
        }
        else if editingStyle == .insert && indexPath.section == 0
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            addNewWord()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
    }
    
    override func viewDidLayoutSubviews()
    {
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.layoutMargins = UIEdgeInsets.zero
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return self.tableView.isEditing
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}


