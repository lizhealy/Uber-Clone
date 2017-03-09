//
//  DriverViewController.swift
//  Uber Clone
//
//  Created by Liz Healy on 2/21/17.
//  Copyright © 2017 netGALAXY Studios. All rights reserved.
//

import UIKit
import Parse

class DriverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var locationManager = CLLocationManager()
    
    var requestUsernames = [String]()
    
    var requestLocations = [CLLocationCoordinate2D]()
    
    var userLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DriverLogoutSegue" {
            
            PFUser.logOut()
            locationManager.stopUpdatingLocation()
            
            self.navigationController?.navigationBar.isHidden = true
            
            print("Logged Out")
            
            
        } else if segue.identifier == "ShowRiderSegue" {
            
            if let destination = segue.destination as? RiderLocationViewController { // segue.destinationViewController  is now segue.destination
                
                if let row = tableView.indexPathForSelectedRow?.row {
                    
                    destination.requestLocation = requestLocations[row]
                    
                    destination.requestUsername = requestUsernames[row]
                    
                }
                
                
            }
            
        }
    
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowRiderSegue", sender: self)
    }

    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requestUsernames.count
        
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "DriverCell")
        
        //Find Distance between user location and request location
        
        let driverCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let riderCLLocation = CLLocation(latitude: requestLocations[indexPath.row].latitude, longitude: requestLocations[indexPath.row].longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        
        let roundedDistance = round(distance * 100)/100
        
        cell.textLabel?.text = requestUsernames[indexPath.row] + " - \(roundedDistance) km away"
        
        
        return cell
        
    }
    
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
        
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Do any additional setup after loading the view.
    }
    

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = manager.location?.coordinate {
            
            userLocation = location
            
            print(location)
            
            let driverLocationQuery = PFQuery(className: "DriverLocation")
            
            driverLocationQuery.whereKey("username", equalTo: PFUser.current()?.username)

            driverLocationQuery.findObjectsInBackground(block: { (objects, error) in
            
                if let driverLocations = objects {
                    
                    for driverLocation in driverLocations {
                        
                        driverLocation["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                        
                        driverLocation.deleteInBackground()
                        
                    }
                }
                        
                
                let driverLocation = PFObject(className: "DriverLocation")
                
                driverLocation["username"] = PFUser.current()?.username
                
                driverLocation["location"] = PFGeoPoint(latitude: self.userLocation.latitude, longitude: self.userLocation.longitude)
                
                driverLocation.saveInBackground()
                
            
            })
            
            let query = PFQuery(className: "RiderRequest")
            
            
            
            query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude))
            
            query.limit = 10
            
            query.findObjectsInBackground(block: {(objects, error) in
            
                if let riderRequests = objects {
                    
                    self.requestUsernames.removeAll()
                    self.requestLocations.removeAll()
                    
                    for riderRequest in riderRequests {
                        
                        if let username = riderRequest["username"] as? String {
                            
                            if riderRequest["driverResponded"] == nil {
                           
                                self.requestUsernames.append(username)
                            
                                self.requestLocations.append(CLLocationCoordinate2D(latitude: (riderRequest["location"] as AnyObject).latitude, longitude: (riderRequest["location"] as AnyObject).longitude))
                                
                            }
                            
                            
                        }
                        
                        
                    }
                    
                    self.tableView.reloadData()
                    
                }
                
            })
            
        }
        
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
