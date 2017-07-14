//
//  EventTableVC.swift
//  FirebaseAssessment
//
//  Created by Dev on 7/13/17.
//  Copyright © 2017 Colin. All rights reserved.
//

import UIKit
import PKHUD

class EventTableVC: UITableViewController {

    var m_selectedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.loadEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return Store.events.count
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            Store.deleteEvent(ID: Store.events[indexPath.row].ID)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.EVENT_TABLEVIEW_CELL, for: indexPath) as! EventTableCell
        
        cell.setEvent(event: Store.events[indexPath.row])
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        m_selectedIndex = indexPath.row
        self.performSegue(withIdentifier: Constants.FormSegue, sender: self)
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == Constants.FormSegue) {
            let formVC = segue.destination as! EventFormVC
            if let _ = sender as? EventTableVC { // tableview selected
                formVC.m_event = Store.events[self.m_selectedIndex]
            }
        }
    }
    
    
    func loadEvents() {
        self.view.isUserInteractionEnabled = false
        HUD.show(.labeledProgress(title: "", subtitle: "Loading..."))
        if Store.watchAddedHandle == 0 {
            Store.loadEvents(callback: { (bLoaded)in
                if (bLoaded) { // Successfully loaded
                    DispatchQueue.main.async {
                        self.view.isUserInteractionEnabled = true
                        HUD.hide()
                        self.tableView.reloadData()
                    }
                } else {
                    self.view.isUserInteractionEnabled = true
                    HUD.hide()
                    HUD.show(.error)
                    self.loadEvents()
                }
            }, eventAdded: {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }, eventUpdated: { (ID) in
                DispatchQueue.main.async {
                    // Search ID and update it only
                    self.tableView.reloadData()
                }
            })
        }
    }

}
