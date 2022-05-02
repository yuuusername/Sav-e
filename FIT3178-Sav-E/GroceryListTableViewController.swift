//
//  GroceryListTableViewController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 27/4/2022.
//

import UIKit

class GroceryListTableViewController: UITableViewController, AddProductDelegate {
    let CELL_ITEM = "itemCell"
    var groceryList: [Product] = []
    
    override func viewDidLoad() {
        //testProducts()
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func addProduct(_ newProduct: Product) -> Bool {
        tableView.performBatchUpdates({
            groceryList.append(newProduct)
            tableView.insertRows(at: [IndexPath(row: groceryList.count - 1, section: 0)], with: .automatic)
        }, completion: nil)
        return true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let itemCell = tableView.dequeueReusableCell(withIdentifier: CELL_ITEM, for: indexPath)
        
        var content = itemCell.defaultContentConfiguration()
        let item = groceryList[indexPath.row]
        content.text = item.productName
        content.secondaryText = "\(item.productPrice!)"
        itemCell.contentConfiguration = content
        
        return itemCell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.performBatchUpdates({
                self.groceryList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }, completion: nil)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    /*
    // DEPRECIATED
    //Add test products
    func testProducts() {
        groceryList.append(Product(name: "Apples", price: 3.00, supermarket: .coles))
        groceryList.append(Product(name: "Oranges", price: 7.99, supermarket: .coles))
        groceryList.append(Product(name: "2L Milk", price: 10.23, supermarket: .coles))
        groceryList.append(Product(name: "Eggs", price: 1.00, supermarket: .coles))
        groceryList.append(Product(name: "Coke", price: 12.00, supermarket: .coles))
    }
    */
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "allProductsSegue" {
            let destination = segue.destination as! AllProductsTableViewController
            destination.productDelegate = self
        }
    }
    
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
