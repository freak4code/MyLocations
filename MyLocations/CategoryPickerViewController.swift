//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Shahriar Nasim Nafi on 3/9/20.
//  Copyright © 2020 Shahriar Nasim Nafi. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {
    
    let locationTypes = [ "No Category",
                          "Masjid",
                          "River",
                          "Apple Store",
                          "Bookstore",
                          "Grocery Store",
                          "Historic Building",
                          "House",
                          "Icecream Vendor",
                          "Landmark",
                          "Park"]
    var selectedCategory: String!
    var selectedIndexPath = IndexPath()
    // weak var delegate: CategoryPickerViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<locationTypes.count{
            if locationTypes[i] == selectedCategory {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    @IBAction func back(){
        navigationController?.popViewController(animated: true)
    }
    
    
    
    // MARK: - Table view data source
    
    //    override func numberOfSections(in tableView: UITableView) -> Int {
    //        // #warning Incomplete implementation, return the number of sections
    //        return 0
    //    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return locationTypes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryName = locationTypes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Categories", for: indexPath)
        cell.textLabel?.text = categoryName
        
        if categoryName == selectedCategory{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        cell.selectedBackgroundView = selection
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row{
            if let newCell = tableView.cellForRow(at: indexPath){
                newCell.accessoryType = .checkmark
            }
            
            if let oldCell = tableView.cellForRow(at: selectedIndexPath){
                oldCell.accessoryType = .none
            }
            
            selectedIndexPath = indexPath
        }
        //delegate?.pickCategory(self, for: locationTypes[indexPath.row])
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectedCategory"{
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell){
                selectedCategory = locationTypes[indexPath.row]
            }
            
            
            
        }
        
        
    }
    
    
}

protocol CategoryPickerViewControllerDelegate: class {
    func pickCategory(_ controller: CategoryPickerViewController, for category: String)
}
