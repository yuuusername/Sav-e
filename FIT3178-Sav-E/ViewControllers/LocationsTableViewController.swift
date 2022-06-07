//
//  LocationsTableViewController.swift
//  FIT3178-Sav-E
//
//  Created by Dylan Hor on 7/6/2022.
//

import UIKit

class LocationsTableViewController: UITableViewController {
    
    let CELL_LOCATION = "locationCell"
    
    weak var mapViewController: MapViewController?
    var locationList = [LocationAnnotation]()
    var isFirstViewApperance = true

    override func viewDidLoad() {
        woolworthsLocations()
        igaLocations()
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstViewApperance {
            mapViewController?.mapView.addAnnotations(locationList)
            isFirstViewApperance = false
        }
    }
    
    func woolworthsLocations() {
        locationList.append(LocationAnnotation(title: "Clayton M-City", subtitle: "7:00am - 11:00pm", supermarket: "w", lat: -37.9213586, long: 145.1398498))
        locationList.append(LocationAnnotation(title: "Clarinda", subtitle: "7:00am - 11:00pm", supermarket: "w", lat: -37.9405927, long: 145.1034342))
        locationList.append(LocationAnnotation(title: "Oakleigh", subtitle: "7:00am - 10:00pm", supermarket: "w", lat: -37.9009232, long: 145.0910968))
        locationList.append(LocationAnnotation(title: "Mount Waverley", subtitle: "7:00am - 9:00pm", supermarket: "w", lat: -37.8784207, long: 145.127147))
        locationList.append(LocationAnnotation(title: "Oakleigh South", subtitle: "7:00am - 10:00pm", supermarket: "w", lat: -37.9232489, long: 145.0816088))
        locationList.append(LocationAnnotation(title: "Springvale", subtitle: "7:00am - 10:00pm", supermarket: "w", lat: -37.9532804, long: 145.1506263))
        locationList.append(LocationAnnotation(title: "Wheelers Hill", subtitle: "7:00am - 10:00pm", supermarket: "w", lat: -37.9096955, long: 145.1897631))
        locationList.append(LocationAnnotation(title: "Chadstone", subtitle: "7:00am - 10:00pm", supermarket: "w", lat: -37.8871335, long: 145.0842483))
        locationList.append(LocationAnnotation(title: "Glen", subtitle: "7:00am - 10:00pm", supermarket: "w", lat: -37.8749341, long: 145.165274))
        locationList.append(LocationAnnotation(title: "Waverley Gardens (Mulgrave)", subtitle: "7:00am - 11:00pm", supermarket: "w", lat: -37.9356063, long: 145.1893668))
    }
    
    func igaLocations() {
        locationList.append(LocationAnnotation(title: "Bentleigh", subtitle: "7:30am - 9:30pm", supermarket: "i", lat: -37.9257837, long: 145.0343498))
        locationList.append(LocationAnnotation(title: "Malvern", subtitle: "7:00am - 9:00pm", supermarket: "i", lat: -37.8533982, long: 145.0414816))
        locationList.append(LocationAnnotation(title: "Ringwood East", subtitle: "7:30am - 8:00pm", supermarket: "i", lat: -37.8121633, long: 145.2513996))
        locationList.append(LocationAnnotation(title: "St Kilda Road", subtitle: "7:00am - 9:00pm", supermarket: "i", lat: -37.829345, long: 144.9706632))
        locationList.append(LocationAnnotation(title: "East Melbourne", subtitle: "7:00am - 10:00pm", supermarket: "i", lat: -37.8096091, long: 144.9854807))
        locationList.append(LocationAnnotation(title: "South Melbourne", subtitle: "6:00am - 11:00pm", supermarket: "i", lat: -37.827487, long: 144.9664409))
        locationList.append(LocationAnnotation(title: "Abbotsford", subtitle: "7:00am - 10:00pm", supermarket: "i", lat: -37.8106998, long: 145.0020418))
        locationList.append(LocationAnnotation(title: "Southbank", subtitle: "8:00am - 9:00pm", supermarket: "i", lat: -37.825867, long: 144.9570046))
        locationList.append(LocationAnnotation(title: "Fairfield", subtitle: "8:00am - 9:00pm", supermarket: "i", lat: -37.7761501, long: 145.0179545))
        locationList.append(LocationAnnotation(title: "Narre Warren North", subtitle: "7:00am - 9:00pm", supermarket: "i", lat: -37.9803594, long: 145.3168788))
        locationList.append(LocationAnnotation(title: "Melbourne", subtitle: "7:00am - 9:00pm", supermarket: "i", lat: -37.816486, long: 144.961032))
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath)
        let location = locationList[indexPath.row]
        
        // Configure the cell
        var content = cell.defaultContentConfiguration()
        content.text = location.title
        if location.supermarket == "i" {
            content.textProperties.color = UIColor(red: 0.60, green: 0.14, blue: 0.14, alpha: 1.00)
        } else {
            content.textProperties.color = UIColor(red: 0.07, green: 0.33, blue: 0.19, alpha: 1.00)
        }
        content.secondaryText = location.subtitle
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mapViewController?.focusOn(annotation: locationList[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
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
