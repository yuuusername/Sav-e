//
//  AllProductsTableViewController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 27/4/2022.
//

import UIKit

class AllProductsTableViewController: UITableViewController {

    override func viewDidLoad() {
        createDefaultProducts()
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source
    
    let SECTION_PRODUCT = 0
    let SECTION_INFO = 1
    let CELL_PRODUCT = "itemCell"
    let CELL_INFO = "totalCell"
    var allProducts: [Product] = []
    weak var productDelegate: AddProductDelegate?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_PRODUCT:
            return allProducts.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_PRODUCT {
            //configure and return a product cell
            let productCell =  tableView.dequeueReusableCell(withIdentifier: CELL_PRODUCT, for: indexPath)
            
            var content = productCell.defaultContentConfiguration()
            let product = allProducts[indexPath.row]
            content.text = product.productName
            content.secondaryText = "\(product.productPrice!)"
            productCell.contentConfiguration = content
            
            return productCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath) as! ProductCountTableViewCell
            
            infoCell.totalLabel?.text = "\(allProducts.count) products in the database"
            
            return infoCell
        }
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_PRODUCT {
            return true
        } else {
            return true
        }
    }

    
    /*
    // USERS SHOULD NOT BE ABLE TO DELETE PRODUCTS FROM THE DATABASE
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_PRODUCT {
            tableView.performBatchUpdates({
                self.allProducts.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.tableView.reloadSections([SECTION_INFO], with: .automatic)
            }, completion: nil)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let productDelegate = productDelegate {
            if productDelegate.addProduct(allProducts[indexPath.row]) {
                navigationController?.popViewController(animated: false)
                return
            }
            else {
                displayMessage(title: "This is probably an error", message: "There should be an error message here, not sure why there isn't tho")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true,completion: nil)
    }
    
    func createDefaultProducts() {
        allProducts.append(Product(name: "Apples", price: 3.00, supermarket: .coles))
        allProducts.append(Product(name: "Oranges", price: 2.60, supermarket: .coles))
        allProducts.append(Product(name: "Pears", price: 4.00, supermarket: .coles))
        allProducts.append(Product(name: "2L Milk", price: 2.00, supermarket: .coles))
        allProducts.append(Product(name: "Bananas", price: 5.99, supermarket: .coles))
        allProducts.append(Product(name: "Peaches", price: 2.99, supermarket: .coles))
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
