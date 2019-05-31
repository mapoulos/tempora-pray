//
//  WorkTableViewController.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 5/23/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import UIKit

class SectionTableViewController: UITableViewController {

    var author = Author()
    var work = Work()
    
    var workSaved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        self.tableView.register(SectionCell.self, forCellReuseIdentifier: cellID)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return work.sections.count
    }

    let cellID = "SectionTableCell"
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SectionCell

//        cell.backgroundColor = .black
        cell.sectionNumber.text = work.sections[indexPath.row].number
        cell.sectionText.text = work.sections[indexPath.row].text
        
        
        //if downloaded, display an icon
        
        //if not download, put a button
        let downloadButton = UIButton(type: .system)
        
        
        downloadButton.backgroundColor = .clear
//        downloadButton.setImage(UIImage(named: "Download_arrow"), for: [])
//        downloadButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
//        cell.uiView.addSubview(downloadButton)
        
//        cell.uiView.addSubview(downloadButton)
        //if downloading, put an activity monitor there

        return cell
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SectionSelected" {
            let rootViewController = segue.destination as! ViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let sectionIndex = indexPath.row
            let section = work.sections[sectionIndex]
            rootViewController.currentMeditation = (author, work, section)
            rootViewController.sectionIndex = sectionIndex
            Preferences.updateDefaults(authorName: author.name, workName: work.name, sectionName: section.number)
            
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */
    @IBAction func downloadButtonPressed(_ sender: Any) {
        
    }
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


class SectionCell : UITableViewCell {
    @IBOutlet var sectionNumber : UILabel!
    @IBOutlet var sectionText : UILabel!
    @IBOutlet var uiView : UIView!
}
