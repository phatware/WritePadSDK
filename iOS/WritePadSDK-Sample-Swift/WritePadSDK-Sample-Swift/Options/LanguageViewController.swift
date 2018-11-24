/* ************************************************************************************* */
/* *    PhatWare WritePad SDK                                                          * */
/* *    LanguageViewController.swift                                                   * */
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

protocol LanguageSelectorDelegate
{
    func languageSelected( _ language : String )
}

class LanguageViewController: UITableViewController
{
    var languages : Dictionary<String,UIImage> = [String:UIImage]()
    
    var selectedIndex : Int! = 0
    var selectedLanguage : String! = nil
    var delegate : LanguageSelectorDelegate?
    var showDone : Bool! = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.title = "Default Language"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        if self.showDone == true
        {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.cancel, target: self, action: #selector(LanguageViewController.CancelButton(_:)))
        }
    }
    
    @objc func CancelButton( _ sender : UIBarButtonItem )
    {
        self.dismiss( animated: true, completion: { () -> Void in
            
        })        
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
        return self.languages.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell : UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "ID1092479864") as UITableViewCell?
        if cell == nil
        {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "ID1092479864")
        }

        // Configure the cell...
        cell!.selectionStyle = UITableViewCellSelectionStyle.none
        cell!.accessoryType = UITableViewCellAccessoryType.none
        
        let index = indexPath.row
        if index < self.languages.count
        {
            let array = Array(self.languages.keys)
            let lang = array[index]
            cell!.textLabel!.text = lang
            cell!.imageView!.image = self.languages[lang]! as UIImage
            if self.selectedLanguage != nil
            {
                if self.selectedLanguage == lang
                {
                    cell!.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }
            else if index == self.selectedIndex
            {
                cell!.accessoryType = UITableViewCellAccessoryType.checkmark
            }
        }
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let index = indexPath.row
        if index < self.languages.count
        {
            self.selectedIndex = index
            let array = Array(self.languages.keys)
            self.selectedLanguage = array[index]
            // tableView.reloadData()
            self.delegate!.languageSelected( self.selectedLanguage! )
            
            if self.showDone == true
            {
                self.dismiss( animated: true, completion: { () -> Void in
                    
                })
            }
            else
            {
                self.navigationController!.popToRootViewController(animated: true)
            }
        }
    }
}
