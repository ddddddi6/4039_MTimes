//
//  MapViewController.swift
//  MTimes
//
//  Created by Dee on 19/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    

    @IBOutlet var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var latitude: String!
    var longitude: String!
    
    var nearbyCinema: NSMutableArray
    required init?(coder aDecoder: NSCoder) {
        self.nearbyCinema = NSMutableArray()
        super.init(coder: aDecoder)
        
        // Define a NSMutableArray to store all cinemas
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager = CLLocationManager()
        
        self.locationManager.delegate = self
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Ask for Authorisation from the User. 
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        self.locationManager.startUpdatingLocation()
        
        self.mapView.showsUserLocation = true
   
        self.mapView.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // get current location
    // solution from: https://www.youtube.com/watch?v=qrdIL44T6FQ
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let location = locations.last! as CLLocation
        
        NSLog("Found \(location.coordinate.latitude) \(location.coordinate.longitude)")
        
        if (self.latitude == nil && self.longitude == nil) {
            self.latitude = String(location.coordinate.latitude)
            self.longitude = String(location.coordinate.longitude)
        
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        
            self.mapView.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
        
            searchNearbyCinema()
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }
    
    // add button for annotation on map
    // solution from: http://stackoverflow.com/questions/28225296/how-to-add-a-button-to-mkpointannotation
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        
        let button = UIButton(type: .DetailDisclosure) as UIButton // button with info sign in it
        
        pinView?.rightCalloutAccessoryView = button
        
        return pinView
    }


    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.performSegueWithIdentifier("CinemaDetailSegue", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CinemaDetailSegue"
        {
            let theDestination : CinemaViewController = segue.destinationViewController as! CinemaViewController
            theDestination.currentCinemaID = self.mapView.selectedAnnotations[0].subtitle!}
    }


    // Search nearby cinema from google map api and check network connection
    func searchNearbyCinema() -> Bool{
        var flag = true as Bool
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + self.latitude + "," + self.longitude + "&radius=50000&types=movie_theater&sensor=true&key=AIzaSyBp1FhLFQV2NCcXkMSO4p4lm3vuFD5g8f8")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                self.parseCinemaJSON(data)
                dispatch_async(dispatch_get_main_queue()) {
                    // drop pins for each cinema on map
                    for cinema in self.nearbyCinema {
                        let c: Cinema = cinema as! Cinema
                        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(c.latitude!), Double(c.longitude!))
                        let objectAnnotation = MKPointAnnotation()
                        objectAnnotation.coordinate = pinLocation
                        objectAnnotation.title = c.name
                        objectAnnotation.subtitle = c.id
                        self.mapView.layer.shadowColor = UIColor.clearColor().CGColor;
                        self.mapView.addAnnotation(objectAnnotation)
                    }
                }
                flag = true
            } else {
                let messageString: String = "Something wrong with the connection"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                flag = false
            }
        }
        task.resume()
        // Download cinemas
        return flag
    }
    
    // Parse the received json result
    func parseCinemaJSON(movieJSON:NSData){
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            NSLog("Found \(json["results"].count) cinemas!")
            
        
            for cinema in json["results"].arrayValue {
                if let
                    latitude = cinema["geometry"]["location"]["lat"].double,
                    longitude = cinema["geometry"]["location"]["lng"].double,
                    name = cinema["name"].string,
                    id = cinema["place_id"].string {
                    let c: Cinema = Cinema(latitude: latitude, longitude: longitude, name: name, id: id)
                    nearbyCinema.addObject(c)
                }
            }
        
        }catch {
            print("JSON Serialization error")
        }
    }
    
    // share the screenshot with external applications
    // solution from: https://www.hackingwithswift.com/example-code/uikit/how-to-share-content-with-uiactivityviewcontroller
    // and http://stackoverflow.com/questions/25448879/how-to-take-full-screen-screenshot-in-swift
    @IBAction func share(sender: UIBarButtonItem) {
        let layer = UIApplication.sharedApplication().keyWindow!.layer
        
        let scale = UIScreen.mainScreen().scale
        
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
