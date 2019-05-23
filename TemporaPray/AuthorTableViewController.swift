//
//  AuthorTableViewController.swift
//  TemporaPray
//
//  Created by Matthew Poulos on 5/14/19.
//  Copyright © 2019 Equulus. All rights reserved.
//

import UIKit

class AuthorTableViewController: UITableViewController {
    
    private static var authors: [Author] = []
    
    public static func setAuthors(_ authorList : [Author]) {
        authors = authorList
    }
    
    // TODO, load the authors here instead of in the main view controller
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return AuthorTableViewController.authors.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let authorsArr = AuthorTableViewController.authors
        var sum = 0
        for author in authorsArr {
            sum += author.works.count
        }
        return sum
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = AuthorTableViewController.authors[section]
        return section.name
    }

    let cellID = "Cell"
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: self.cellID)
//            cell.textLabel!.textColor = .white
//            cell.back  = .black
        }
        let row = indexPath.row
        let section = indexPath.section
        
        //TODO add some error echecking here
        let authors = AuthorTableViewController.authors
        
        let author = authors[indexPath.section]
        let works = author.works
        
        let work = author.works[indexPath.row]
        let name = work.name
        cell.textLabel!.text = name

        return cell
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
