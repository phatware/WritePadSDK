/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    WordListViewController.swift                                                   * */
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

class WordListViewController: UITableViewController, EditWordItemDelegate
{
    var wordList : NSMutableArray? = nil
    var modified : Bool! = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "AddButton:")
        self.tableView.autoresizesSubviews = true
        self.tableView.separatorInset = UIEdgeInsetsZero
        self.title = "Corrector Word List"
        
        wordList = RecognizerManager.sharedManager().getCorrectorWordList()!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let viewController = EditWordItemViewController(style: UITableViewStyle.Grouped)
        let item : NSDictionary? = wordList![indexPath.row] as? NSDictionary
        
        viewController.newItem = false
        viewController.fromWordField!.text = (item!.objectForKey( ackeyWordFrom ) as? String)!
        viewController.toWordField!.text = (item!.objectForKey( ackeyWordTo ) as? String)!
        viewController.flags = (item!.objectForKey( ackeyFlags )!.intValue as Int32)
        viewController.delegate = self
        viewController.itemIndex = indexPath.row
        self.navigationController!.pushViewController(viewController, animated: true )
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func updateWordListItem( itemView : EditWordItemViewController )
    {
        modified = true
        
        let newWord : NSDictionary = [ ackeyWordFrom : itemView.fromWordField!.text!,
            ackeyWordTo : itemView.toWordField!.text!,
            ackeyFlags  : NSNumber(int: itemView.flags) ]
       
        if itemView.newItem
        {
            wordList!.insertObject(newWord as NSDictionary, atIndex: 0)
        }
        else
        {
            wordList!.replaceObjectAtIndex( itemView.itemIndex, withObject: newWord as NSDictionary)
        }
        self.tableView.reloadData()
    }
    
    
    func reloadWordList()
    {
        self.tableView.reloadData()
    }
    
    @objc func AddButton( sender : UIBarButtonItem )
    {
        let viewController = EditWordItemViewController(style: UITableViewStyle.Grouped)
        viewController.newItem = true
        viewController.delegate = self
        viewController.flags = WCF_IGNORECASE | WCF_ALWAYS
        self.navigationController!.pushViewController(viewController, animated: true )
    }
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear( animated )

        self.reloadWordList()
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear( animated )
        
        if (wordList != nil && modified == true)
        {
            RecognizerManager.sharedManager().newWordListFromWordList( wordList! as [AnyObject] )
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
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if wordList == nil
        {
            return 0
        }
        return wordList!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell? = nil
        cell = tableView.dequeueReusableCellWithIdentifier("ID1092479864") as UITableViewCell?
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ID1092479864")
        }
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator

        if indexPath.row < wordList?.count
        {
            let item : NSDictionary? = wordList![indexPath.row] as? NSDictionary
            var text : String = (item!.objectForKey( ackeyWordFrom ) as? String)!
            text += "  ⇒  "
            text += (item!.objectForKey( ackeyWordTo ) as? String)!
            cell!.textLabel!.text = text
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle
    {
        if (indexPath.section == 0 )
        {
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
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
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if (editingStyle == .Delete && indexPath.section == 0 && indexPath.row < wordList?.count)
        {
            // Delete the row from the data source
            wordList!.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            modified = true
        }
        else if editingStyle == .Insert && indexPath.section == 0
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            // addNewWord()
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
}


