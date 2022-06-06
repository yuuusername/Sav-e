//
//  AllProductsTableViewController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 27/4/2022.
//

import UIKit


class AllProductsTableViewController: UITableViewController, UISearchBarDelegate {
    let CELL_ITEM = "itemCell"
    var currentRequestIndex: Int = 0
    var woolworthsItems = [ItemData]()
    var indicator = UIActivityIndicatorView()
    weak var productDelegate: CompareProductDelegate?
    weak var databaseController: DatabaseProtocol?
    var itemSelected: ItemData?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        appDelegate.woolworthsItems.removeAll()
        
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
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.compItemData = appDelegate.woolworthsItems[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func requestItemsNamed(_ itemName: String) async {
        var searchURLComponents = URLComponents()
        searchURLComponents.scheme = "https"
        searchURLComponents.host = "www.woolworths.com.au"
        searchURLComponents.path = "/apis/ui/Search/products"
        searchURLComponents.queryItems = [URLQueryItem(name: "pageSize", value: "36"), URLQueryItem(name: "searchTerm", value: itemName)]
        
        guard let requestURL = searchURLComponents.url else {
            print("Invalid URL.")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw PriceListError.invalidServerResponse
            }
            DispatchQueue.main.async {
                self.indicator.stopAnimating()
            }
            do {
                let decoder = JSONDecoder()
                let productsData = try decoder.decode(ProductsData.self, from: data)
                if let items = productsData.products {
                    appDelegate.woolworthsItems.append(contentsOf: items)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.displayMessage(title: "Sorry, " + itemName + " wasn't found", message: "Check your spelling or use a different query and try again.")
                    }
                }
            }
            catch {
                print(error)
            }
        }
        catch let error {
            print(error)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        appDelegate.woolworthsItems.removeAll()
        tableView.reloadData()
        
        guard let searchText = searchBar.text?.lowercased() else {
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
        return appDelegate.woolworthsItems.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //configure and return a product cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_ITEM, for: indexPath)
        let item = appDelegate.woolworthsItems[indexPath.row]
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        
        // Configure the cell
        var content = cell.defaultContentConfiguration()
        if item.price != nil {
            content.text = item.name
            if item.price == 0.0 {
                content.secondaryText = formatter.string(for: item.wasPrice!)
            } else {
                content.secondaryText = formatter.string(for: item.price!)
            }
            cell.contentConfiguration = content
        }
        
        return cell
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        false
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
        if (segue.identifier == "compareProductSegue") {
            let destination = segue.destination as! CompareProductsTableViewController
            destination.compItemData = itemSelected
        }
    }
    */
}
