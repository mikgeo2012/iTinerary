//
//  DetailViewController.swift
//  iTinerary
//
//  Created by Mikhail George on 3/13/16.
//  Copyright © 2016 Mikhail George. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate {

    // MARK: - Properties
    
    @IBOutlet var mapView: MKMapView?
    
    var searchController:UISearchController!
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

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.configureView()
        // Do any additional setup after loading the view, typically from a nib.
        self.mapView?.delegate = self
        self.mapView?.showsScale = true
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
        UIDevice.currentDevice().setValue(value, forKey: "orientation")
    }
    
    
    // MARK: - Methods
    
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
            //let newStop = travelLocation(stopName: newStopTitle!, mapCoordinate: newStopCoord)
            //self.travelLocations.append(newStop)
            
        }
        
        
        
    }
    
    func centerMapOnRegion(location: CLLocationCoordinate2D, mapSpan: Double) {
        let tempSpan = MKCoordinateSpanMake(mapSpan, mapSpan)
        let coordRegion = MKCoordinateRegionMake(location, tempSpan)
        mapView?.setRegion(coordRegion, animated: true)
    }
    
    /*func fitMapViewToAnnotaionList() {
        let mapEdgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        var zoomRect:MKMapRect = MKMapRectNull
        let annotationsCount = self.mapView!.annotations.count
        for index in 0..<annotationsCount {
            let annotation = self.mapView!.annotations[index]
            let aPoint:MKMapPoint = MKMapPointForCoordinate(annotation.coordinate)
            let rect:MKMapRect = MKMapRectMake(aPoint.x, aPoint.y, 0.1, 0.1)
            
            if MKMapRectIsNull(zoomRect) {
                zoomRect = rect
            } else {
                zoomRect = MKMapRectUnion(zoomRect, rect)
            }
        }
        self.setVisibleMapRect(zoomRect, edgePadding: mapEdgePadding, animated: true)
    }*/
    
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
                mapView?.addAnnotations(annotations)
            }
            
            if (!sleepLocations.isEmpty) {
                var annotations = [MKAnnotation]()
                for s in sleepLocations {
                    let annotation = sleepAnnotation(title: s.name!, nights: String(s.nights), address: s.address!, coordinate: s.mapCoordinate!)
                    annotations.append(annotation)
                }
                mapView?.addAnnotations(annotations)
            }
            return true
        }
        return false
    }
    
    
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

    /*func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
            if let location = view.annotation as? viewAnnotation {
                let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                location.mapItem().openInMapsWithLaunchOptions(launchOptions)
            } else if let location = view.annotation as? sleepAnnotation {
                let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                location.mapItem().openInMapsWithLaunchOptions(launchOptions)
            }
            
            
    }*/
    
}




