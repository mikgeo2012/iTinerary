//
//  DetailViewController.swift
//  iTinerary
//
//  Created by Mikhail George on 3/13/16.
//  Copyright © 2016 Mikhail George. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController {

    
    @IBOutlet var overviewMap: MKMapView!


    var detailItem: travelLocation? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

