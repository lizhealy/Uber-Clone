//
//  RiderLocationViewController.swift
//  Uber Clone
//
//  Created by Liz Healy on 2/23/17.
//  Copyright © 2017 netGALAXY Studios. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RiderLocationViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var requestUsername = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("Location: ")
        print(requestLocation)
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = requestLocation
        
        annotation.title = requestUsername
        
        mapView.addAnnotation(annotation)
        
        
    }
    
    @IBAction func acceptOrCancel(_ sender: Any) {
        
        let query = PFQuery(className: "RiderRequest")
        
        query.whereKey("username", equalTo: requestUsername)
        
        query.findObjectsInBackground(block: { (objects, error) in
        
            if error != nil {
                
                print(error)
                
            } else {
                
                if let riderRequests = objects {
                    
                    for riderRequest in riderRequests {
                        
                        riderRequest["driverResponded"] = PFUser.current()?.username
                        
                        riderRequest.saveInBackground()
                        
                        let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                        
                        CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                        
                            if let placemarks = placemarks {
                                
                                if placemarks.count > 0 {
                                    
                                    let mKPlacemark = MKPlacemark(placemark: placemarks[0])
                                    
                                    let mapItem = MKMapItem(placemark: mKPlacemark)
                                    
                                    mapItem.name = self.requestUsername
                                    
                                    let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                    
                                    mapItem.openInMaps(launchOptions: launchOptions)
                                    
                                    
                                }
                            }
                        
                        })
                        
                        
                    }
                }
                
            }
        
        
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
