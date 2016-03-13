/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    UserDictViewController.swift                                                   * */
/* *    Created by Stanislav Miasnikov on 4/19/15                                      * */
/* *    Copyright (c) 2008-2016 PhatWare(r) Corp. All rights reserved.                 * */
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
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tableView.autoresizesSubviews = true
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.title = "User Dictionary"
        self.newWordField = createTextField()
    }
    
    func createTextField() -> UITextField
    {
        let frame : CGRect = CGRect(x: 0.0, y: 0.0, width: kTextFieldWidth, height: kTextFieldHeight)
        let returnTextField : UITextField = UITextField(frame: frame)
    
        returnTextField.borderStyle = UITextBorderStyle.RoundedRect
        returnTextField.font = UIFont.systemFontOfSize( 18.0 )
        returnTextField.placeholder = "Enter New Word"
        returnTextField.backgroundColor = UIColor.whiteColor()
        returnTextField.autocorrectionType = UITextAutocorrectionType.No	// no auto correction support
        returnTextField.autocapitalizationType = UITextAutocapitalizationType.None
        returnTextField.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        returnTextField.delegate = self
        returnTextField.borderStyle = UITextBorderStyle.None
        returnTextField.keyboardType = UIKeyboardType.Default
        returnTextField.returnKeyType = UIReturnKeyType.Done
        returnTextField.clearButtonMode = UITextFieldViewMode.WhileEditing // has a clear 'x' button to the right
    
        return returnTextField
    }
    
    func addNewWord()
    {
        if newWordField!.text!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
        {
            newWordField!.resignFirstResponder()
            let str : String = newWordField!.text!
            let newWord = str.stringByReplacingOccurrencesOfString( " ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            if newWord.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
            {
                userWords!.insertObject(newWord, atIndex: 0)
                modified = true
                tableView.reloadData()
            }
        }
        newWordField!.text = ""
    }
    
    override func setEditing(editing: Bool, animated: Bool)
    {
        super.setEditing(editing, animated: animated)
        if editing == true
        {
            tableView.insertSections( NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Bottom)
            if self.newWordField != nil
            {
                newWordField!.becomeFirstResponder()
            }
        }
        else
        {
            tableView.deleteSections( NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Top)
            if self.newWordField != nil
            {
                self.newWordField!.resignFirstResponder()
                addNewWord()
            }
        }
        // self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func reloadDictionary()
    {
        userWords = RecognizerManager.sharedManager().getUserWords()!
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear( animated )
        
        self.reloadDictionary()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear( animated )
        
        if self.newWordField != nil
        {
            self.newWordField!.resignFirstResponder()
            addNewWord()
        }
        if (userWords != nil && modified == true)
        {
            RecognizerManager.sharedManager().newUserDictFromWordList( userWords! as [AnyObject] )
            modified = false
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return tableView.editing == true ? 2 : 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (tableView.editing == true && section == 0)
        {
            return 1
        }
        if userWords == nil
        {
            return 0
        }
        return userWords!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell? = nil
        if (tableView.editing == true && indexPath.section == 0)
        {
            cell = tableView.dequeueReusableCellWithIdentifier("ID1092378783") as UITableViewCell?
            if cell == nil
            {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ID1092378783")
            }
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
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
            cell = tableView.dequeueReusableCellWithIdentifier("ID1092479864") as UITableViewCell?
            if cell == nil
            {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ID1092479864")
            }
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
            cell!.accessoryType = UITableViewCellAccessoryType.None
            cell!.textLabel!.text = userWords![indexPath.row] as? String
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        if ( self.tableView.editing == true )
        {
            if (indexPath.section == 0 )
            {
                return UITableViewCellEditingStyle.Insert
            }
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if ( tableView.editing == false )
        {
            return
        }
        if (editingStyle == .Delete && indexPath.section == 1 && indexPath.row < userWords?.count)
        {
            // Delete the row from the data source
            userWords!.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            modified = true
        }
        else if editingStyle == .Insert && indexPath.section == 0
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            addNewWord()
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    override func viewDidLayoutSubviews()
    {
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.tableView.layoutMargins = UIEdgeInsetsZero
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        return self.tableView.editing
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
}


