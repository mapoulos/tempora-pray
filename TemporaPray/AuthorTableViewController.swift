//
//  AuthorTableViewController.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 5/14/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import UIKit

class AuthorTableViewController: UITableViewController {
    
    var authors: [Author] = []
    
    
    
    // TODO, load the authors here instead of in the main view controller
    let headerID = "Header"
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: self.headerID)
        self.navigationController?.navigationBar.isHidden = false
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return authors.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        
        return authors[section].works.count
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        return authors[section].name
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UITableViewHeaderFooterView {
        let h = tableView.dequeueReusableHeaderFooterView(withIdentifier: self.headerID)!
        if h.viewWithTag(1) == nil {
            h.backgroundView = UIView()
            h.backgroundView?.backgroundColor = .gray
            let label = UILabel()
            label.tag = 1
            label.font = UIFont(name:"Baskerville", size: 22)
            label.textColor = .white
            label.backgroundColor = .clear
            h.contentView.addSubview(label)
            //add constraints perhaps?
        }
        let label = h.contentView.viewWithTag(1) as! UILabel
        label.text = authors[section].name
        return h
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workCell", for: indexPath) as! WorkCell

        
        
        let author = authors[indexPath.section]
        let work = author.works[indexPath.row]
        let name = work.name
        cell.workNameLabel.text = name
        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let sectionTableViewController =  SectionTableViewController()
//        let indexPath = self.tableView.indexPathForSelectedRow!
//        let authorIndex = indexPath.section
//        let workIndex = indexPath.row
//        let work = self.authors[authorIndex].works[workIndex]
//        sectionTableViewController.work = work
//        self.navigationController!.pushViewController(sectionTableViewController, animated: true)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectWorkToSelectSection" {
            let sectionTableViewController = segue.destination as! SectionTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            let authorIndex = indexPath.section
            let workIndex = indexPath.row
            let work = self.authors[authorIndex].works[workIndex]
            sectionTableViewController.author = self.authors[authorIndex]
            sectionTableViewController.work = work
            
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

class WorkCell : UITableViewCell {
    @IBOutlet var workNameLabel : UILabel!
}
