//
//  GroceryListTableViewController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 27/4/2022.
//

import UIKit


// MARK: - Table View Controller
class GroceryListTableViewController: UITableViewController, DatabaseListener {
    let SECTION_ITEM = 0
    let SECTION_INFO = 1
    let CELL_ITEM = "itemCell"
    let CELL_INFO = "totalCell"
    var groceryList: [Product] = []
    var listenerType: ListenerType = .list
    var woolworthsId: String?
    var woolworthsPrice: Double = 0.0
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        //testProducts()
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func onAllItemsChange(change: DatabaseChange, items: [Product]) {
        
    }
    
    func onListChange(change: DatabaseChange, listItems: [Product]) {
        groceryList = listItems
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_ITEM:
            return groceryList.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_ITEM {
            // Configure and return an item cell
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ITEM, for: indexPath) as! ProductTableViewCell
            let grocery = groceryList[indexPath.row]
            let formatter = NumberFormatter()
            formatter.locale = Locale.current
            formatter.numberStyle = .currency
            
            // Configure the cell
            cell.nameLabel.text = grocery.name
            if grocery.woolworthsPrice > grocery.igaPrice {
                cell.priceLabel.text = formatter.string(for: grocery.igaPrice)
                cell.supermarketLabel.text = "IGA"
                cell.priceLabel.textColor = UIColor(red: 0.60, green: 0.14, blue: 0.14, alpha: 1.00)
            } else if grocery.igaPrice > grocery.woolworthsPrice {
                cell.priceLabel.text = formatter.string(for: grocery.woolworthsPrice)
                cell.supermarketLabel.text = "Woolworths"
                cell.priceLabel.textColor = UIColor(red: 0.07, green: 0.33, blue: 0.19, alpha: 1.00)
            } else {
                cell.priceLabel.text = formatter.string(for: grocery.woolworthsPrice)
                cell.supermarketLabel.text = "Both"
                cell.priceLabel.textColor = UIColor(red: 0.55, green: 0.45, blue: 0.00, alpha: 1.00)
            }
            return cell
        } else {
            // Configure and return an info cell instead
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath) as! ProductCountTableViewCell
            
            
            if groceryList.isEmpty {
                infoCell.gLTotalLabel?.text =  "There are no items in your grocery list. Tap the shopping cart to start adding items."
            } else if groceryList.count == 1 {
                infoCell.gLTotalLabel?.text = "\(groceryList.count) item in your grocery list"
            } else {
                infoCell.gLTotalLabel?.text = "\(groceryList.count) items in your grocery list"
            }
            
            return infoCell
        }
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == SECTION_ITEM {
            return true
        } else {
            return false
        }
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_ITEM {
            self.databaseController?.removeItemFromList(item: groceryList[indexPath.row], list: databaseController!.defaultList)
        }
    }
    
    func addProduct(_ newItem: Product) -> Bool {
        return databaseController?.addItemToList(item: newItem, list: databaseController!.defaultList) ?? false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
