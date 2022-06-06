//
//  CompareProductsTableViewController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 25/5/2022.
//

import UIKit
import SwiftSoup

extension UIViewController {
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true,completion: nil)
    }
}

struct igaItem {
    var name: String
    var price: Double
    var jpgURLString: String
}

enum ParserError: Error {
    case invalidURL
    case invalidData
}

enum CompareListError: Error {
    case invalidServerResponse
}

class CompareProductsTableViewController: UITableViewController, UISearchBarDelegate, DatabaseListener {
    let CELL_ITEM = "itemCell"
    var currentRequestIndex: Int = 0
    var products = [igaItem]()
    var comparisonProd = [ItemData]()
    var indicator = UIActivityIndicatorView()
    var listenerType = ListenerType.items
    weak var compItemData: ItemData?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All Products"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        
        // Ensures that the search bar is always visible
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Add loading indicator view
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([indicator.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        super.viewDidLoad()
        compareProduct(appDelegate.compItemData!)
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    func compareProduct(_ newProduct: ItemData) {
        products.removeAll()
        tableView.reloadData()
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        Task {
            URLSession.shared.invalidateAndCancel()
            currentRequestIndex = 0
            await requestItemsNamed(newProduct.name!)
        }
    }
    
    func requestItemsNamed(_ itemName: String) async {
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "new.igashop.com.au"
        searchURLComponents.path = "/sm/pickup/rsid/52511/results"
        searchURLComponents.queryItems = [URLQueryItem(name: "q", value: itemName)]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
    
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw CompareListError.invalidServerResponse
            }
            guard let htmlString = String(data: data, encoding: .utf8) else {
                throw ParserError.invalidData
            }
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            do {
                let doc: Document = try SwiftSoup.parse(htmlString)
                
                let cardElements = try doc.select("article:nth-child(1)")
                if cardElements.array().count == 0 {
                    DispatchQueue.main.async {
                        self.displayMessage(title: "Sorry, " + itemName + " wasn't found", message: "Check your spelling or use a different query and try again.")
                    }
                } else {
                    for element: Element in cardElements.array() {
                        
                        let name = try element.select("article:nth-child(1) > span:nth-child(7) > div:nth-child(1)").first()?.text()
                        let formatName = name?.replacingOccurrences(of: "Open product description", with: "")
                        let price = try element.select("article:nth-child(1) > div:nth-child(9) > span:nth-child(1) > span:nth-child(1)").first()?.text()
                        let formatPrice = price?.replacingOccurrences(of: " avg/ea", with: "")
                        let svgURLString = try element.select("img:nth-child(1)").first()?.attr("src")
                        
                        if let formatName = formatName, let formatPrice = formatPrice, let svgURLString = svgURLString {
                            products.append(igaItem(name: formatName, price: Double(formatPrice.dropFirst()) ?? 0, jpgURLString: svgURLString))
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            catch {
                print("Caught Error: " + error.localizedDescription)
            }
        }
        catch let error {
            print(error)
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        products.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text else {
            return
        }
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        
        Task {
            URLSession.shared.invalidateAndCancel()
            currentRequestIndex = 0
            await requestItemsNamed(searchText)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ITEM, for: indexPath)
        let item = products[indexPath.row]
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        // Configure the cell...
        var content = cell.defaultContentConfiguration()
        content.text = item.name
        content.secondaryText = formatter.string(for: item.price)
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = databaseController?.addProduct(name: appDelegate.compItemData!.name!, igaPrice: products[indexPath.row].price, woolworthsPrice: appDelegate.compItemData!.price!)
        let itemAdded = databaseController?.addItemToList(item: item!, list: databaseController!.defaultList) ?? false
        if itemAdded {
            navigationController?.popViewController(animated: false)
            return
        }
        displayMessage(title: "\(item!.name ?? "That item") is already in your grocery list", message: "Please remove the item from your list first before adding it again")
        tableView.deselectRow(at: indexPath, animated: true)
        //let _ = databaseController?.addProduct(itemData: item)
        //tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - DatabaseProtocol Methods
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
        // Do nothing
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
        if segue.identifier == "compareProductSegue" {
            let destination = segue.destination as! AllProductsTableViewController
            compItemData = destination.itemSelected
        }
    }
    */
}
