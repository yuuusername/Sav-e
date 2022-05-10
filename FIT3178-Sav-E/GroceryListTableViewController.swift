//
//  GroceryListTableViewController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 27/4/2022.
//

import UIKit


enum PriceListError: Error {
    case invalidServerResponse
}


// MARK: - Product Data
class ProductPrice: Codable {
    var Price: Double
    
    private enum RootKeys: String, CodingKey {
        case Product
    }
    
    required init(from decoder: Decoder) throws {
        // Get root container
        let rootContainer = try decoder.container(keyedBy: RootKeys.self)
        let priceContainer = try rootContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .Product)
        self.Price = try priceContainer.decode(Double.self, forKey: .Price)
    }
    
    private enum CodingKeys: String, CodingKey {
        case Price
    }
}


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
            let itemCell = tableView.dequeueReusableCell(withIdentifier: CELL_ITEM, for: indexPath)
            
            var content = itemCell.defaultContentConfiguration()
            let item = groceryList[indexPath.row]
            
            // MARK: - Request price for product
            let requestURL = URL(string: "https://www.woolworths.com.au/apis/ui/product/detail/\(groceryList[indexPath.row].woolworthsId)")
            if let requestURL = requestURL {
                Task {
                    do {
                        let (data, response) = try await URLSession.shared.data(from: requestURL)
                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else {
                                  throw PriceListError.invalidServerResponse
                              }
                        let decoder = JSONDecoder()
                        let itemPrice = try decoder.decode(ProductPrice.self, from: data)
                        item.woolworthsPrice = itemPrice.Price
                        await MainActor.run {
                            tableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                    catch {
                        //print("Caught Error: " + error.localizedDescription)
                        print(String(describing: error))
                    }
                }
            }
            
            content.text = item.productName
            content.secondaryText = String(item.woolworthsPrice)
            itemCell.contentConfiguration = content
            
            return itemCell
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
    
    
    /*
    func woolworthsPriceGetter(woolworthsId: String) -> Bool {
        let requestURL = URL(string: "https://www.woolworths.com.au/api/v3/ui/schemaorg/product/\(woolworthsId)")
        if let requestURL = requestURL {
            Task { () -> Bool in
                
                do {
                    let (data, response) = try await URLSession.shared.data(from: requestURL)
                    guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                              throw PriceListError.invalidServerResponse
                          }
                    let decoder = JSONDecoder()
                    let item = try decoder.decode(ProductPrice.self, from: data)
                    woolworthsPrice = item.price
                    tableView.reloadData()
                    return true
                }
                catch {
                    //print("Caught Error: " + error.localizedDescription)
                    print(String(describing: error))
                    return false
                }
            }
        }
        return false
    }
    */
    
    
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
