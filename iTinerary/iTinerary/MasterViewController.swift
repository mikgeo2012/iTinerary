//
//  MasterViewController.swift
//  iTinerary
//
//  Created by Mikhail George on 3/13/16.
//  Copyright © 2016 Mikhail George. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class MasterViewController: UITableViewController, UISearchBarDelegate {

    var detailViewController: DetailViewController? = nil
    
    var travelLocations = [travelLocation]()
    
    var searchController:UISearchController!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        //let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        //self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        let start = travelLocation(stopName: "Home", coordinate: Point(42.48, -83.49))
        start.addViewLocation("Emagine Novi", description: "Movie", address: "test", coordinate: Point(42.4909, -83.4859))
        start.addViewLocation("Ajishin restaurant", description: "Reservations on monday for 2", address: "42270 Grand River Ave", coordinate: Point(42.4790, -83.4631))
        start.addSleepLocation("Residence Inn Detroit Novi", address: "27477 Cabaret Dr", nights: "2", coordinate: Point(42.4925, -83.4878))
        let s1 = travelLocation(city: "Nashville", state: "TN", country: "USA", coordinate: Point(36.16, -86.78))
        s1.addViewLocation("Tennessee Museum", description: "Hopefully go here on the first day", address:  "505 Deaderick St", coordinate: Point(36.1646, -86.7819))
        s1.addSleepLocation("Hampton Inn", address: "310 4th Ave S", nights: "1", coordinate: Point(36.1574, -86.7746))
        s1.addViewLocation("Visual Arts Center", description: "Bought tickets already", address: "919 Broadway St.", coordinate: Point(36.1575, -86.7838))
        s1.addSleepLocation("Hotel Indigo", address: "301 Union St", nights: "1", coordinate: Point(36.1652, -86.7797))
        s1.addViewLocation("12th & Porter", description: "Make reservations before going", address: "114 12th Ave N", coordinate: Point(36.1579, -86.7881))
        let s2 = travelLocation(stopName: "Grandma's House", coordinate: Point(35.60, -92.87))
        let s3 = travelLocation(city: "Salt Lake City", state: "UT", country: "USA", coordinate: Point(40.75, -111.94))
        
        travelLocations.append(start)
        travelLocations.append(s1)
        travelLocations.append(s2)
        travelLocations.append(s3)
        
        self.refreshControl?.addTarget(self, action: "refreshTable", forControlEvents:UIControlEvents.ValueChanged)
        s1.printLocations()
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.Portrait.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshTable() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
        
        //self.refreshControl?.endRefreshing()
    }

    /*func insertNewObject(sender: AnyObject) {
        var alert = UIAlertController(title: "New Stop", message: "Enter the location of the new stop.", preferredStyle: .ActionSheet)
        
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "City"
        })
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "State"
        })
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Country"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let address = "\(alert.textFields![0] as UITextField), \(alert.textFields![1] as UITextField), \(alert.textFields![2] as UITextField)"
            
            var geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address, completionHandler: {(placemarks: [CLPlacemark]?, error: NSError?) in
                    let placemark = placemarks![0]
                    let coords = CLLocationCoordinate2D(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
                    let tempStop = travelLocation(city: alert.textFields![0].text!, state: alert.textFields![1].text!, country: alert.textFields![2].text!, coordinate: coords)
                    self.travelLocations.insert(tempStop, atIndex: 0)
        })
        
        // 4. Present the alert.
        self.presentViewController(alert, animated: true, completion: nil)
        
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }))
    }*/
    
    
    @IBAction func showSearchBar(sender: AnyObject) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        presentViewController(searchController, animated: true, completion: nil)
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchBar.text
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            let newStopTitle = searchBar.text
            let newStopCoord = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            let newStop = travelLocation(stopName: newStopTitle!, mapCoordinate: newStopCoord)
            self.travelLocations.append(newStop)
            self.refreshTable()
        }
        
        
            
    }
    
     /*func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = searchText
        localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            let newStopTitle = searchText
            let newStopCoord = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
            let newStop = travelLocation(stopName: newStopTitle, mapCoordinate: newStopCoord)
            self.travelLocations.append(newStop)
        }

    }*/
    
    
    

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let stop = travelLocations[indexPath.row] 
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = stop
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return travelLocations.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let stop = travelLocations[indexPath.row]
        cell.textLabel?.text = stop.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.showsReorderControl = true
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        if (destinationIndexPath.row < sourceIndexPath.row) {
            let movingStop = travelLocations[sourceIndexPath.row]
            for i in sourceIndexPath.row.stride(to: destinationIndexPath.row, by: -1) {
                travelLocations[i] = travelLocations[i-1]
            }
            travelLocations[destinationIndexPath.row] = movingStop
        } else if (destinationIndexPath.row > sourceIndexPath.row) {
            let movingStop = travelLocations[sourceIndexPath.row]
            for i in sourceIndexPath.row.stride(to: destinationIndexPath.row, by: 1) {
                travelLocations[i] = travelLocations[i+1]
            }
            travelLocations[destinationIndexPath.row] = movingStop
        }

    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            travelLocations.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

