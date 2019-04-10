/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    WordListViewController.swift                                                   * */
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
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(WordListViewController.AddButton(_:)))
        self.tableView.autoresizesSubviews = true
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.title = "Corrector Word List"
        
        wordList = RecognizerManager.shared().getCorrectorWordList()!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let viewController = EditWordItemViewController(style: UITableView.Style.grouped)
        if let item : NSDictionary = wordList![indexPath.row] as? NSDictionary {
        
            viewController.newItem = false
            viewController.fromWordField!.text = (item[ackeyWordFrom] as? String) ?? ""
            viewController.toWordField!.text = (item[ackeyWordTo] as? String) ?? ""
            viewController.flags = ((item[ackeyFlags] as! NSNumber).int32Value as Int32)
            viewController.delegate = self
            viewController.itemIndex = indexPath.row
            self.navigationController!.pushViewController(viewController, animated: true )
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func updateWordListItem( _ itemView : EditWordItemViewController )
    {
        modified = true
        
        let newWord : NSDictionary = [ ackeyWordFrom : itemView.fromWordField!.text!,
            ackeyWordTo : itemView.toWordField!.text!,
            ackeyFlags  : NSNumber(value: itemView.flags as Int32) ]
       
        if itemView.newItem
        {
            wordList!.insert(newWord as NSDictionary, at: 0)
        }
        else
        {
            wordList!.replaceObject( at: itemView.itemIndex, with: newWord as NSDictionary)
        }
        self.tableView.reloadData()
    }
    
    
    func reloadWordList()
    {
        self.tableView.reloadData()
    }
    
    @objc func AddButton( _ sender : UIBarButtonItem )
    {
        let viewController = EditWordItemViewController(style: UITableView.Style.grouped)
        viewController.newItem = true
        viewController.delegate = self
        viewController.flags = WCF_IGNORECASE | WCF_ALWAYS
        self.navigationController!.pushViewController(viewController, animated: true )
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear( animated )

        self.reloadWordList()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear( animated )
        
        if (wordList != nil && modified == true)
        {
            RecognizerManager.shared().newWordList( fromWordList: wordList! as [AnyObject] )
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if wordList == nil
        {
            return 0
        }
        return wordList!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell? = nil
        cell = tableView.dequeueReusableCell(withIdentifier: "ID1092479864") as UITableViewCell?
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ID1092479864")
        }
        cell!.selectionStyle = UITableViewCell.SelectionStyle.none
        cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator

        if indexPath.row < wordList?.count
        {
            let item : NSDictionary? = wordList![indexPath.row] as? NSDictionary
            var text : String = (item!.object( forKey: ackeyWordFrom ) as? String)!
            text += "  ⇒  "
            text += (item!.object( forKey: ackeyWordTo ) as? String)!
            cell!.textLabel!.text = text
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if (indexPath.section == 0 )
        {
            return UITableViewCell.EditingStyle.delete
        }
        return UITableViewCell.EditingStyle.none
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
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if (editingStyle == .delete && indexPath.section == 0 && indexPath.row < wordList?.count)
        {
            // Delete the row from the data source
            wordList!.removeObject(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            modified = true
        }
        else if editingStyle == .insert && indexPath.section == 0
        {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            // addNewWord()
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
}


