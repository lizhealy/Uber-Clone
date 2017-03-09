//
//  RiderViewController.swift
//  Uber Clone
//
//  Created by Liz Healy on 2/21/17.
//  Copyright © 2017 netGALAXY Studios. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RiderViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var driverStatus: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var requestButton: UIButton!
    
    var riderRequestActive = true
    
    var driverOnTheWay = false
    
    var locationManager = CLLocationManager()
    
    var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    @IBAction func requestUber(_ sender: Any) {
        
        if riderRequestActive  {
            
            requestButton.setTitle("Request an Uber", for: [])
            
            riderRequestActive = false
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: {(objects, error) in
             
                if error != nil {
                    
                    print(error)
                    
                } else {
                    
                    if let riderRequests = objects {
                        
                        for riderRequest in riderRequests {
                            
                            riderRequest.deleteInBackground()
                            
                            print("Cancelled Uber")
                            
                            self.driverStatus.text = "Cancelled Uber"
                            
                        }
                    }
                    
                }
            })
            
            
        } else {
            
            if location.latitude != 0 && location.longitude != 0 {
                
                riderRequestActive = true
                
                self.requestButton.setTitle("Cancel Uber", for: [])
                
                let riderRequest = PFObject(className: "RiderRequest")
                
                riderRequest["username"] = PFUser.current()?.username
                
                riderRequest["location"] = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
                
                riderRequest.saveInBackground(block: {(success, error) in
                    
                    if success {
                        
                        print("Requested an uber")
                        
                        self.driverStatus.text = "No drivers yet"
                        
                        
                        
                    } else {
                        
                        self.createAlert(title: "Error", message: "Could not request an uber")
                        
                        self.requestButton.setTitle("Request an Uber", for: [])
                        
                        self.riderRequestActive = false
                        
                        
                    }
                    
                    
                })

            } else {
    
                createAlert(title: "Error", message: "Could not detect your location")
            
            }
        
        }
        
    }
 


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        requestButton.isHidden = true
        
        let query = PFQuery(className: "RiderRequest")
        
        query.whereKey("username", equalTo: (PFUser.current()?.username)!)
        
        query.findObjectsInBackground(block: {(objects, error) in
            
            if let objects = objects {
                
                if objects.count > 0 {
                    
                    self.riderRequestActive = true
                    
                    self.requestButton.setTitle("Cancel Uber", for: [])
                    
                }
                
                self.requestButton.isHidden = false
                
            }
        })


        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let userLocation = manager.location?.coordinate {
            
            location = CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude)
            
            if driverOnTheWay == false {
            
                let latDelta: CLLocationDegrees = 0.01
                let lonDelta: CLLocationDegrees = 0.01
                let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
                let region: MKCoordinateRegion = MKCoordinateRegion(center: location, span: span)
            
                self.mapView.setRegion(region, animated: true)
            
                self.mapView.removeAnnotations(self.mapView.annotations)
                let annotation = MKPointAnnotation()
            
                annotation.coordinate = location
                annotation.title = "Your Location"
            
                self.mapView.addAnnotation(annotation)
            }
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("username", equalTo: (PFUser.current()?.username)!)
            
            query.findObjectsInBackground(block: {(objects, error) in
                
                if error != nil {
                    
                    print(error)
                    
                } else {
                    
                    if let riderRequests = objects {
                        
                        for riderRequest in riderRequests {
                            
                            riderRequest["location"] = PFGeoPoint(latitude: userLocation.latitude, longitude: userLocation.longitude)
                            
                            riderRequest.saveInBackground()
                            
                        }
                    }
                    
                }
            })
            
            print(location)
            
        }
        
        if riderRequestActive == true {
            
            let query = PFQuery(className: "RiderRequest")
            
            query.whereKey("username", equalTo: PFUser.current()?.username)
            
            query.findObjectsInBackground(block: { (objects, error) in
            
                if error != nil {
                    
                    print(error)
                    
                } else {
                    
                    if let riderRequests = objects {
                        
                        for riderRequest in riderRequests {
                            
                            if let driverUsername = riderRequest["driverResponded"] {
                                
                                let query = PFQuery(className: "DriverLocation")
                                
                                query.whereKey("username", equalTo: driverUsername)
                                
                                query.findObjectsInBackground(block: { (objects, error) in
                                
                                    if let driverLocations = objects {
                                        
                                        for driverLocationObject in driverLocations {
                                            
                                            if let driverLocation = driverLocationObject["location"] as? PFGeoPoint {
                                                
                                                self.driverOnTheWay = true
                                                
                                                let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                
                                                let riderCLLocation = CLLocation(latitude: self.location.latitude, longitude: self.location.longitude)
                                                
                                                let distance = riderCLLocation.distance(from: driverCLLocation) / 1000
                                                
                                                let roundedDistance = round(distance * 100) / 100
                                                
                                                
                                                self.driverStatus.text = "Driver is \(roundedDistance) km away!"
                                                
                                                let latDelta = abs(driverLocation.latitude - self.location.latitude) * 2 + 0.005
                                                
                                                let lonDelta = abs(driverLocation.longitude - self.location.longitude) * 2 + 0.005
                                                
                                                let region = MKCoordinateRegion(center: self.location, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
                                                
                                                
                                                self.mapView.removeAnnotations(self.mapView.annotations)
                                                
                                                self.mapView.setRegion(region, animated: true)
                                                
                                                let userLocationAnnotation = MKPointAnnotation()
                                                
                                                userLocationAnnotation.coordinate = self.location
                                                
                                                userLocationAnnotation.title = "Your Location"

                                                self.mapView.addAnnotation(userLocationAnnotation)
                                                
                                                let driverLocationAnnotation = MKPointAnnotation()
                                                
                                                driverLocationAnnotation.coordinate = CLLocationCoordinate2D(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
                                                
                                                driverLocationAnnotation.title = "Your Driver"
                                                
                                                self.mapView.addAnnotation(driverLocationAnnotation)
                                                
                                            }
                                            
                                        }
                                    }
                                
                                })
                                
                            }
                            
                            
                            
                        }
                        
                    }
                    
                }
            
            })
            
        }
    
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "RiderLogoutSegue" {
            
            PFUser.logOut()
            locationManager.stopUpdatingLocation()
            
            print("Logged Out")
        }
    }

    @IBAction func logout(_ sender: Any) {
        
        performSegue(withIdentifier: "RiderLogoutSegue", sender: self)
        
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
