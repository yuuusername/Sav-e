//
//  CompareProductsTableViewController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 25/5/2022.
//

import UIKit
import SwiftSoup

struct igaItem {
    var name: String
    var price: String
    var jpgURLString: String
}

enum ParserError: Error {
    case invalidURL
    case invalidData
}

class CompareProductsTableViewController: UITableViewController {
    var products: [igaItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        Task {
            do {
                guard let igaURL = URL(string: "https://new.igashop.com.au/sm/pickup/rsid/52511/results?q=apple") else {
                    throw ParserError.invalidURL
                }
                let (data, _) = try await URLSession.shared.data(from: igaURL)
                guard let htmlString = String(data: data, encoding: .utf8) else {
                    throw ParserError.invalidData
                }
                
                let doc: Document = try SwiftSoup.parse(htmlString)
                
                let cardElements = try doc.select("article:nth-child(1)")
                for element: Element in cardElements.array() {
                    
                    let name = try element.select("article:nth-child(1) > span:nth-child(7) > div:nth-child(1)").first()?.text()
                    let formatName = name?.replacingOccurrences(of: "Open product description", with: "")
                    let price = try element.select("article:nth-child(1) > div:nth-child(9) > span:nth-child(1) > span:nth-child(1)").first()?.text()
                    let formatPrice = price?.replacingOccurrences(of: " avg/ea", with: "")
                    let svgURLString = try element.select("img:nth-child(1)").first()?.attr("src")
                    
                    if let formatName = formatName, let formatPrice = formatPrice, let svgURLString = svgURLString {
                        products.append(igaItem(name: formatName, price: formatPrice, jpgURLString: svgURLString))
                    }
                    print(try element.text())
                }
                
                await MainActor.run {
                    self.tableView.reloadData()
                }
            }
            catch {
                fatalError(error.localizedDescription)
            }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)

        let benefit = products[indexPath.row]
        
        // Configure the cell...
        var content = cell.defaultContentConfiguration()
        content.text = benefit.name
        content.secondaryText = benefit.price
        cell.contentConfiguration = content
        
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
