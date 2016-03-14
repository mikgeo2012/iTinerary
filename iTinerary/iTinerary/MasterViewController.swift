//
//  MasterViewController.swift
//  iTinerary
//
//  Created by Mikhail George on 3/13/16.
//  Copyright © 2016 Mikhail George. All rights reserved.
//

import UIKit
import CoreLocation

class MasterViewController: UIViewController, UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    var travelLocations = [travelLocation]()


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
        
        let start = travelLocation(stopName: "Home", coordinate: Point(42.48, -83.49), travelIndex: 1)
        let s1 = travelLocation(city: "Nashville", state: "TN", country: "USA", coordinate: Point(36.16, -86.78), travelIndex: 2)
        let s2 = travelLocation(stopName: "Grandma's House", coordinate: Point(35.60, -92.87), travelIndex: 3)
        let s3 = travelLocation(city: "Salt Lake City", state: "UT", country: "USA", coordinate: Point(40.75, -111.94), travelIndex: 4)
        
        travelLocations.append(start)
        travelLocations.append(s1)
        travelLocations.append(s2)
        travelLocations.append(s3)
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    /*override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            travelLocations.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }*/


}

