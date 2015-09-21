/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    EditWordItemViewController.swift                                               * */
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

protocol EditWordItemDelegate
{
     func updateWordListItem( itemView : EditWordItemViewController )
}

class EditWordItemViewController: UITableViewController, UITextFieldDelegate
{
    var flags : Int32 = 0
    var newItem : Bool = false
    let wordEditLeftOffset : CGFloat = 17.0
    var delegate : EditWordItemDelegate? = nil
    var itemIndex : Int = 0

    enum EditWordListSection : Int
    {
        // recognizer
        case FromWord_Section = 0
        case ToWord_Section = 1
        case Options_Section = 2
        case Total_Sections = 3
    }

    enum EditWordFlagsRow : Int
    {
        // recognizer
        case IgnoreCase_Row = 0
        case Always_Row = 1
        case Disable_Row = 2
        case Total_Rows = 3
    }
    
    var toWordField : UITextField? = nil
    var fromWordField : UITextField? = nil

    override init(style: UITableViewStyle)
    {
        super.init(style: style)
        self.toWordField = createTextField( EditWordListSection.ToWord_Section.rawValue )
        self.toWordField!.placeholder = "Corrected Word"
        self.fromWordField = createTextField( EditWordListSection.FromWord_Section.rawValue )
        self.fromWordField!.placeholder = "Misspelled Word"
    }

    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init!(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "CancelButton:")
        self.title = "Edit Word Correction"
    }

    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear( animated )
        
        if (self.delegate != nil && self.fromWordField!.text!.lengthOfBytesUsingEncoding( NSUTF8StringEncoding ) > 0
            && self.toWordField!.text!.lengthOfBytesUsingEncoding( NSUTF8StringEncoding ) > 0)
        {
            self.delegate!.updateWordListItem( self )
        }
    }
    
    func createTextField( tag : Int ) -> UITextField
    {
        let frame : CGRect = CGRect(x: 0.0, y: 0.0, width: kTextFieldWidth, height: kTextFieldHeight)
        let returnTextField : UITextField = UITextField(frame: frame)
        
        returnTextField.borderStyle = UITextBorderStyle.RoundedRect
        returnTextField.font = UIFont.systemFontOfSize( 18.0 )
        returnTextField.backgroundColor = UIColor.whiteColor()
        returnTextField.autocorrectionType = UITextAutocorrectionType.No	// no auto correction support
        returnTextField.autocapitalizationType = UITextAutocapitalizationType.None
        returnTextField.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        returnTextField.delegate = self
        returnTextField.borderStyle = UITextBorderStyle.None
        returnTextField.keyboardType = UIKeyboardType.Default
        returnTextField.returnKeyType = UIReturnKeyType.Done
        returnTextField.tag = tag
        returnTextField.clearButtonMode = UITextFieldViewMode.WhileEditing // has a clear 'x' button to the right
        
        return returnTextField
    }

    func createSwitch( on : Bool, tag: Int ) -> UISwitch
    {
        let sw : UISwitch = UISwitch()
        sw.addTarget(self, action: "switchAction:", forControlEvents: UIControlEvents.ValueChanged )
        sw.on = on;
        sw.tag = tag;
        return sw
    }
    
    @objc func switchAction( sender : UISwitch )
    {
        switch sender.tag
        {
        case EditWordFlagsRow.IgnoreCase_Row.rawValue :
            if sender.on
            {
                flags |= WCF_IGNORECASE;
            }
            else
            {
                flags &= ~WCF_IGNORECASE;
            }
            break
            
        case EditWordFlagsRow.Disable_Row.rawValue :
            if sender.on
            {
                flags |= WCF_DISABLED;
            }
            else
            {
                flags &= ~WCF_DISABLED;
            }
            break
            
        case EditWordFlagsRow.Always_Row.rawValue :
            if sender.on
            {
                flags |= WCF_ALWAYS;
            }
            else
            {
                flags &= ~WCF_ALWAYS;
            }
            break
            
        default :
            break
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
        return EditWordListSection.Total_Sections.rawValue
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == EditWordListSection.Options_Section.rawValue
        {
            return EditWordFlagsRow.Total_Rows.rawValue
        }
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell? = nil
        switch indexPath.section
        {
        case EditWordListSection.FromWord_Section.rawValue,
                    EditWordListSection.ToWord_Section.rawValue
                    where indexPath.row == 0 :
            indexPath.section == 0
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
            frame.size.width -= (2.0 * wordEditLeftOffset)
            let editField : UITextField! = (indexPath.section == EditWordListSection.FromWord_Section.rawValue)
                ? fromWordField! : toWordField!
            editField.frame =  frame
            cell!.addSubview( editField! )
            cell!.accessoryView = editField
            
        case EditWordListSection.Options_Section.rawValue :
            cell = tableView.dequeueReusableCellWithIdentifier("ID1092479864") as UITableViewCell?
            if cell == nil
            {
                cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ID1092479864")
            }
            cell!.selectionStyle = UITableViewCellSelectionStyle.None
            cell!.accessoryType = UITableViewCellAccessoryType.None
            switch indexPath.row
            {
            case EditWordFlagsRow.IgnoreCase_Row.rawValue :
                cell!.accessoryView = createSwitch( (0 != (flags & WCF_IGNORECASE)), tag:indexPath.row )
                cell!.textLabel!.text = "Ignore Case"

            case EditWordFlagsRow.Always_Row.rawValue :
                cell!.accessoryView = createSwitch( (0 != (flags & WCF_ALWAYS)), tag:indexPath.row )
                cell!.textLabel!.text = "Always Replace"

            case EditWordFlagsRow.Disable_Row.rawValue :
                cell!.accessoryView = createSwitch( (0 != (flags & WCF_DISABLED)), tag:indexPath.row )
                cell!.textLabel!.text = "Disabled"
                
            default :
                break
            }
        default :
            break
        }

        return cell!
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
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }

}
