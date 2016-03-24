//
//  DetailViewController.swift
//  iTinerary
//
//  Created by Mikhail George on 3/13/16.
//  Copyright © 2016 Mikhail George. All rights reserved.
//

import UIKit
import MapKit
import Contacts

class DetailViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    // MARK: - Properties
    
    @IBOutlet var mapView: MKMapView?
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    
    var locationManager = CLLocationManager()
    
    //var searchController:UISearchController!
    var localSearchRequest:MKLocalSearchRequest!
    var localSearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!

    
    var detailItem: travelLocation? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    
    // MARK: - Initialize

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            let stopCoords = detail.mapCoordinate
            self.centerMapOnRegion(stopCoords, mapSpan: 0.3)
            let addedAnnotations = self.addAnnotationsToMap(detail)
            if (!addedAnnotations) {
                self.centerMapOnRegion(stopCoords, mapSpan: 0.15)
            } else {
                self.mapView?.showAnnotations((self.mapView?.annotations)!, animated: true)
            }

        } else {
            let coords = CLLocationCoordinate2D(latitude: CLLocationDegrees(40.33), longitude: CLLocationDegrees(-100.69))
            self.centerMapOnRegion(coords, mapSpan: 1.0)
        
        }
    }
    
    func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            mapView!.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureView()
        // Do any additional setup after loading the view, typically from a nib.
        /*let tap = UITapGestureRecognizer(target: self, action: "dropPin:")
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        mapView?.addGestureRecognizer(tap)*/
        
        
        //tap.delegate = self
        self.mapView?.delegate = self
        self.mapView?.showsScale = true
        self.tapGesture.delegate = self
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        checkLocationAuthorizationStatus()
    }
    
    
    
    
    // MARK: - Methods
    
    /*@IBAction func showSearchBar(sender: AnyObject) {
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        
        let alertController = UIAlertController(title: "New Point of Interest", message: "Select which type of location you are trying to add.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            NSLog("Cancel pressed")
        }
        alertController.addAction(cancelAction)
        
        let SightAction = UIAlertAction(title: "New Sight", style: .Default) { (action) in
            var tfield: UITextField!
            
            let newAlertController = UIAlertController(title: "Add Description", message: nil, preferredStyle: .Alert)
            newAlertController.addTextFieldWithConfigurationHandler { (textfield: UITextField!) in
                textfield.placeholder = "Add a note or description"
                textfield.keyboardType = .Default
                tfield = textfield
                
            }
            let newCancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                NSLog("Cancel pressed")
            }
            newAlertController.addAction(newCancelAction)
            let newOKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.isNewSleep = false
                self.isNewSight = true
                self.newSightDesc = tfield.text!
                self.presentViewController(self.searchController, animated: true, completion: nil)
            }
            newAlertController.addAction(newOKAction)
            self.presentViewController(newAlertController, animated: true, completion: nil)
        }
        alertController.addAction(SightAction)
        
        let SleepAction = UIAlertAction(title: "New Accommodation", style: .Default) { (action) in
            
            var tfield: UITextField!
            
            let newAlertController = UIAlertController(title: "Number of nights?", message: nil, preferredStyle: .Alert)
            newAlertController.addTextFieldWithConfigurationHandler { (textfield: UITextField!) in
                textfield.placeholder = ""
                textfield.keyboardType = .NumberPad
                tfield = textfield
                
            }
            let newCancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                NSLog("Cancel pressed")
            }
            newAlertController.addAction(newCancelAction)
            let newOKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.isNewSleep = true
                self.isNewSight = false
                self.newSleepNumNights = tfield.text!
                self.presentViewController(self.searchController, animated: true, completion: nil)
            }
            newAlertController.addAction(newOKAction)
            self.presentViewController(newAlertController, animated: true, completion: nil)
            
        }
        alertController.addAction(SleepAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
        
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
            
            if (self.isNewSight) {
                let name = localSearchResponse?.mapItems[0].placemark.name
                let addr = localSearchResponse?.mapItems[0].placemark.addressDictionary![CNPostalAddressStreetKey] as? String
                let newStopCoord = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                print(name)
                print("\(newStopCoord.latitude), \(newStopCoord.longitude)")
                self.detailItem?.addViewLocation(name!, description: self.newSightDesc, address: addr, mapCoordinate: newStopCoord)
            } else {
                let name = localSearchResponse?.mapItems[0].placemark.name
                let addr = localSearchResponse?.mapItems[0].placemark.addressDictionary![CNPostalAddressStreetKey] as? String
                let newStopCoord = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude: localSearchResponse!.boundingRegion.center.longitude)
                print(name)
                print("\(newStopCoord.latitude), \(newStopCoord.longitude)")
                self.detailItem?.addSleepLocation(name!, address: addr, nights: self.newSleepNumNights, mapCoordinate: newStopCoord)
            }
            
            self.detailItem?.printLocations()
            self.addAnnotationsToMap(self.detailItem!)
            self.mapView?.showAnnotations((self.mapView?.annotations)!, animated: true)
        }
        
        
        
    }*/
    
    
    
    @IBAction func addLocation(sender: UITapGestureRecognizer) {
        let tempCoords = sender.locationInView(self.mapView)
        let newCoords = self.mapView?.convertPoint(tempCoords, toCoordinateFromView: self.mapView)
        
        let alertController = UIAlertController(title: "New Point of Interest", message: "Select which type of location you are trying to add.", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            NSLog("Cancel pressed")
        }
        alertController.addAction(cancelAction)
        
        let SightAction = UIAlertAction(title: "New Sight", style: .Default) { (action) in
            var tfield: UITextField!
            var tfield2: UITextField!
            
            let newAlertController = UIAlertController(title: "Add New Sight", message: nil, preferredStyle: .Alert)
            newAlertController.addTextFieldWithConfigurationHandler { (textfield: UITextField!) in
                textfield.placeholder = "Add a name"
                textfield.keyboardType = .Default
                tfield2 = textfield
                
            }
            newAlertController.addTextFieldWithConfigurationHandler { (textfield: UITextField!) in
                textfield.placeholder = "Add a note or description"
                textfield.keyboardType = .Default
                tfield = textfield
                
            }
            let newCancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                NSLog("Cancel pressed")
            }
            newAlertController.addAction(newCancelAction)
            let newOKAction = UIAlertAction(title: "OK", style: .Default) { (action) in

                
                var addr = ""
                
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoords!.latitude, longitude: newCoords!.longitude), completionHandler: {(placemarks, error) -> Void in
                    if error != nil {
                        print("Reverse geocoder failed with error" + error!.localizedDescription)
                        return
                    }
                    
                    if placemarks!.count > 0 {
                        let pm = placemarks![0]
                        
                        if (pm.thoroughfare != nil) && (pm.subThoroughfare != nil) {
                            addr = pm.subThoroughfare! + " " + pm.thoroughfare!
                        } else if (pm.thoroughfare != nil) {
                            addr = pm.thoroughfare!
                        }
                        
                        print (addr)
                        
                    }
                    
                    
                    
                })
                
                self.detailItem?.addViewLocation(tfield2.text!, description: tfield.text!, address: addr, mapCoordinate: newCoords!)
                let annotation = viewAnnotation(title: tfield2.text!, description: tfield.text!, address: addr, coordinate: newCoords!)
                self.mapView?.addAnnotation(annotation)
            
                
            }
            newAlertController.addAction(newOKAction)
            self.presentViewController(newAlertController, animated: true, completion: nil)
        }
        alertController.addAction(SightAction)
            
        let SleepAction = UIAlertAction(title: "New Accommodation", style: .Default) { (action) in
            
            var tfield: UITextField!
            var tfield2: UITextField!
            
            let newAlertController = UIAlertController(title: "Add New Accommodation", message: nil, preferredStyle: .Alert)
            newAlertController.addTextFieldWithConfigurationHandler { (textfield: UITextField!) in
                textfield.placeholder = "Add a name"
                textfield.keyboardType = .Default
                tfield2 = textfield
                
            }
            newAlertController.addTextFieldWithConfigurationHandler { (textfield: UITextField!) in
                textfield.placeholder = "Number of nights?"
                textfield.keyboardType = .NumberPad
                tfield = textfield
                
            }
            let newCancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
                NSLog("Cancel pressed")
            }
            newAlertController.addAction(newCancelAction)
            let newOKAction = UIAlertAction(title: "OK", style: .Default) { (action) in

                
                var addr = ""
                
                CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoords!.latitude, longitude: newCoords!.longitude), completionHandler: {(placemarks, error) -> Void in
                    if error != nil {
                        print("Reverse geocoder failed with error" + error!.localizedDescription)
                        return
                    }
                    
                    if placemarks!.count > 0 {
                        let pm = placemarks![0]
                        
                        if (pm.thoroughfare != nil) && (pm.subThoroughfare != nil) {
                            addr = pm.subThoroughfare! + " " + pm.thoroughfare!
                        } else if (pm.thoroughfare != nil) {
                            addr = pm.thoroughfare!
                        }
                        
                        
                        
                    }
                    
                    
                    
                })
                print(addr)
                self.detailItem?.addSleepLocation(tfield2.text!, address: addr, nights: tfield.text!, mapCoordinate: newCoords!)
                let annotation = sleepAnnotation(title: tfield2.text!, nights: tfield.text!, address: addr, coordinate: newCoords!)
                self.mapView?.addAnnotation(annotation)
                
            }
            newAlertController.addAction(newOKAction)
            self.presentViewController(newAlertController, animated: true, completion: nil)
            
        }
        alertController.addAction(SleepAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
        
    }
    
    
    
    /*func addSightAnnotationFromTouch(gestureRecognizer: UIGestureRecognizer, textFieldTitle: UITextField, textFieldDescription: UITextField) {
        
        let tempCoords = gestureRecognizer.locationInView(self.mapView)
        let newCoords = self.mapView?.convertPoint(tempCoords, toCoordinateFromView: self.mapView)
        
        var addr = self.findAddress(newCoords!)
        
        self.detailItem?.addViewLocation(textFieldTitle.text!, description: textFieldDescription.text!, address: addr, mapCoordinate: newCoords!)
        
        let newAnnotation = viewAnnotation(title: textFieldTitle.text!, description: textFieldDescription.text!, address: addr, coordinate: newCoords!)
        
        self.mapView!.addAnnotation(newAnnotation)
        
    }
    
    func TestaddSightAnnotationFromTouch(gestureRecognizer: UIGestureRecognizer, textFieldTitle: String, textFieldDescription: String) {
        
        let tempCoords = gestureRecognizer.locationInView(self.mapView)
        let newCoords = self.mapView?.convertPoint(tempCoords, toCoordinateFromView: self.mapView)
        
        var addr = self.findAddress(newCoords!)
        
        self.detailItem?.addViewLocation(textFieldTitle, description: textFieldDescription, address: addr, mapCoordinate: newCoords!)
        
        let newAnnotation = viewAnnotation(title: textFieldTitle, description: textFieldDescription, address: addr, coordinate: newCoords!)
        
        self.mapView!.addAnnotation(newAnnotation)
        
    }
    
    func addSleepAnnotationFromTouch(gestureRecognizer: UIGestureRecognizer, textFieldTitle: UITextField, textFieldDescription: UITextField) {
        
        let tempCoords = gestureRecognizer.locationInView(self.mapView)
        let newCoords = self.mapView?.convertPoint(tempCoords, toCoordinateFromView: self.mapView)
        
        var addr = self.findAddress(newCoords!)
        
        self.detailItem?.addSleepLocation(textFieldTitle.text!, address: addr, nights: textFieldDescription.text!, mapCoordinate: newCoords!)
        
        let newAnnotation = sleepAnnotation(title: textFieldTitle.text!, nights: textFieldDescription.text!, address: addr, coordinate: newCoords!)
        
        self.mapView!.addAnnotation(newAnnotation)
        
    }
    
    func TestaddSleepAnnotationFromTouch(gestureRecognizer: UIGestureRecognizer, textFieldTitle: String, textFieldDescription: String) {
        
        let tempCoords = gestureRecognizer.locationInView(self.mapView)
        let newCoords = self.mapView?.convertPoint(tempCoords, toCoordinateFromView: self.mapView)
        
        var addr = self.findAddress(newCoords!)
        
        self.detailItem?.addSleepLocation(textFieldTitle, address: addr, nights: textFieldDescription, mapCoordinate: newCoords!)
        
        let newAnnotation = sleepAnnotation(title: textFieldTitle, nights: textFieldDescription, address: addr, coordinate: newCoords!)
        
        self.mapView!.addAnnotation(newAnnotation)
        
    }*/
    
    
    func centerMapOnRegion(location: CLLocationCoordinate2D, mapSpan: Double) {
        let tempSpan = MKCoordinateSpanMake(mapSpan, mapSpan)
        let coordRegion = MKCoordinateRegionMake(location, tempSpan)
        self.mapView?.setRegion(coordRegion, animated: true)
    }
    
    
    
    func addAnnotationsToMap(stop: travelLocation) -> Bool {
        let viewLocations = stop.viewLocations
        let sleepLocations = stop.sleepLocations
        if (!viewLocations.isEmpty && !sleepLocations.isEmpty) {
            if (!viewLocations.isEmpty) {
                var annotations = [MKAnnotation]()
                for v in viewLocations {
                    print(v.name)
                    let annotation = viewAnnotation(title: v.name, description: v.description, address: v.address, coordinate: v.mapCoordinate!)
                    annotations.append(annotation)
                }
                self.mapView?.addAnnotations(annotations)
            }
            
            if (!sleepLocations.isEmpty) {
                var annotations = [MKAnnotation]()
                for s in sleepLocations {
                    print(s.name)
                    let annotation = sleepAnnotation(title: s.name!, nights: s.nights!, address: s.address, coordinate: s.mapCoordinate!)
                    annotations.append(annotation)
                }
                self.mapView?.addAnnotations(annotations)
            }
            return true
        }
        return false
    }
    
    /*func addAnnotationToMap(annotation: MKAnnotation) -> Bool {
        if let viewAnn = annotation as? viewAnnotation {
            print(viewAnn.title)
            self.mapView?.addAnnotation(viewAnn)
            return true
        }
        
        if let sleepAnn = annotation as? sleepAnnotation {
            print(sleepAnn.title)
            self.mapView?.addAnnotation(sleepAnn)
            return true
        }
        
        return false
    }*/
    
    
    // MARK: - MKMapViewDelegation implementation
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? viewAnnotation {
            let identifier = "viewPin"
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if (view == nil) {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                let tempPoint = self.mapView?.convertCoordinate(annotation.coordinate, toPointToView: nil)
                view!.image = UIImage(named: "viewImage")
                view?.frame = CGRect(origin: tempPoint!, size: CGSize(width: 25, height: 25))
                view!.canShowCallout = true
                view!.calloutOffset = CGPoint(x: -5, y: 5)
                view!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            } else {
                view!.annotation = annotation
            }
            return view
        } else if let annotation = annotation as? sleepAnnotation {
            let identifier = "sleepPin"
            var view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            if (view == nil) {
                view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                let tempPoint = self.mapView?.convertCoordinate(annotation.coordinate, toPointToView: nil)
                view!.image = UIImage(named: "sleepImage")
                view?.frame = CGRect(origin: tempPoint!, size: CGSize(width: 20, height: 20))
                view!.canShowCallout = true
                view!.calloutOffset = CGPoint(x: -5, y: 5)
                view!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            } else {
                view!.annotation = annotation
            }
            return view
        } else {
            return nil
        }
        
    }
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let sightView = view.annotation as? viewAnnotation {
                let tempPoint = self.mapView?.convertCoordinate(sightView.coordinate, toPointToView: nil)
                
                let newOrigin = CGPoint(x: 0, y: 20)
                
                let tempLabel = UILabel(frame: CGRectMake(50, -100, 120, 40))
                tempLabel.backgroundColor = UIColor.whiteColor()
                tempLabel.textColor = UIColor.blackColor()
                tempLabel.alpha = 0.90
                tempLabel.font = UIFont.boldSystemFontOfSize(12)
                tempLabel.textAlignment = NSTextAlignment.Center
                tempLabel.text = sightView.locationName
                view.addSubview(tempLabel)

            }
        
            if let sleepView = view.annotation as? sleepAnnotation {
                let tempPoint = self.mapView?.convertCoordinate(sleepView.coordinate, toPointToView: nil)
                
                let newOrigin = CGPoint(x: 0, y: 20)
                
                let tempLabel = UILabel(frame: CGRectMake(50, -100, 120, 40))
                tempLabel.backgroundColor = UIColor.whiteColor()
                tempLabel.textColor = UIColor.blackColor()
                tempLabel.alpha = 0.90
                tempLabel.font = UIFont.boldSystemFontOfSize(12)
                tempLabel.textAlignment = NSTextAlignment.Center
                tempLabel.text = sleepView.locationName
                view.addSubview(tempLabel)
            }
            
        }
            
    }
    
    
    // MARK: - Update user position
    func mapView(mapView: MKMapView, didUpdateUserLocation
        userLocation: MKUserLocation) {
            if(MKMapRectContainsPoint(mapView.visibleMapRect, MKMapPointForCoordinate((userLocation.location?.coordinate)!)))
            {
                mapView.centerCoordinate = userLocation.location!.coordinate
            }
            
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer :UIGestureRecognizer) -> Bool {
            return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let tempView = touch.view as? MKAnnotationView {
            return false
        }
        return true
    }
    
}




