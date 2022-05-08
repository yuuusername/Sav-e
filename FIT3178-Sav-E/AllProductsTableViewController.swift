//
//  AllProductsTableViewController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 27/4/2022.
//

import UIKit


class AllProductsTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    override func viewDidLoad() {
        // createDefaultProducts()
        filteredItems = allItems
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All Products"
        navigationItem.searchController = searchController
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        allItems = items
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func onListChange(change: DatabaseChange, listItems: [Product]) {
        // Do nothing
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_ITEM {
            let item = filteredItems[indexPath.row]
            databaseController?.deleteProduct(item: item)
        }
    }
    
    // MARK: - Database adoption
    var listenerType = ListenerType.items
    weak var databaseController: DatabaseProtocol?
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        if searchText.count > 0 {
            filteredItems = allItems.filter({(product:Product) -> Bool in
                return (product.productName?.lowercased().contains(searchText) ?? false)
            })
        } else {
            filteredItems = allItems
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    let SECTION_ITEM = 0
    let SECTION_INFO = 1
    let CELL_ITEM = "itemCell"
    let CELL_INFO = "totalCell"
    var allItems: [Product] = []
    var filteredItems: [Product] = []
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_ITEM:
            return filteredItems.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_ITEM {
            //configure and return a product cell
            let productCell = tableView.dequeueReusableCell(withIdentifier: CELL_ITEM, for: indexPath)
            
            var content = productCell.defaultContentConfiguration()
            let product = filteredItems[indexPath.row]
            content.text = product.productName
            productCell.contentConfiguration = content
            
            return productCell
        } else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath) as! ProductCountTableViewCell
            if filteredItems.isEmpty {
                infoCell.totalLabel?.text = "No products in the database"
            } else if filteredItems.count == 1 {
                infoCell.totalLabel?.text = "\(filteredItems.count) product in the database"
            } else {
                infoCell.totalLabel?.text = "\(filteredItems.count) products in the database"
            }
            return infoCell
        }
    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == SECTION_ITEM {
            return true
        } else {
            return true
        }
    }

    
    /*
    // USERS SHOULD NOT BE ABLE TO DELETE PRODUCTS FROM THE DATABASE
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let index = self.allProducts.firstIndext(of: filteredProducts[indexPath.row]) {
            self.allProdcuts.remover(at: index)
        }
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
        let item = filteredItems[indexPath.row]
        let itemAdded = databaseController?.addItemToList(item: item, list: databaseController!.defaultList) ?? false
        if itemAdded {
            navigationController?.popViewController(animated: false)
            return
        }
        displayMessage(title: "Item Already in List", message: "The \(item.productName ?? "product with the same name") is already in your grocery list")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true,completion: nil)
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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
}
