//
//  MapViewController.swift
//  MTimes
//
//  Created by Dee on 19/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import MapKit
// external library from https://github.com/SwiftyJSON/SwiftyJSON
import SwiftyJSON
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    

    @IBOutlet var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var latitude: String!
    var longitude: String!
    
    var cinemaID: String!
    
    // Define a NSMutableArray to store all cinemas
    var nearbyCinema: NSMutableArray
    required init?(coder aDecoder: NSCoder) {
        self.nearbyCinema = NSMutableArray()
        super.init(coder: aDecoder)
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
    
    // get current location and then search nearby cinemas
    // solution from: https://www.youtube.com/watch?v=qrdIL44T6FQ
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
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
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // add info button for each annotation on map to jump to cinema detail controller
    // solution from: http://stackoverflow.com/questions/28225296/how-to-add-a-button-to-mkpointannotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            //return nil
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
        } else {
            pinView?.annotation = annotation
        }
        
        let button = UIButton(type: .detailDisclosure) as UIButton // button with info sign in it
        
        pinView?.rightCalloutAccessoryView = button
        
        return pinView
    }


    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            self.cinemaID = self.mapView.selectedAnnotations[0].subtitle!
            self.performSegue(withIdentifier: "CinemaDetailSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CinemaDetailSegue"
        {
            let theDestination : CinemaViewController = segue.destination as! CinemaViewController
            theDestination.currentCinemaID = self.cinemaID}
    }


    // Search nearby cinema from google map api and check network connection
    // solution from: https://developers.google.com/places/web-service/search#PlaceSearchRequests
    func searchNearbyCinema() -> Bool{
        var flag = true as Bool
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + self.latitude + "," + self.longitude + "&radius=50000&types=movie_theater&sensor=true&key=AIzaSyBp1FhLFQV2NCcXkMSO4p4lm3vuFD5g8f8")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data {
                self.parseCinemaJSON(data)
                DispatchQueue.main.async {
                    // drop pins for each cinema on map
                    for cinema in self.nearbyCinema {
                        let c: Cinema = cinema as! Cinema
                        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(Double(c.latitude!), Double(c.longitude!))
                        let objectAnnotation = MKPointAnnotation()
                        objectAnnotation.coordinate = pinLocation
                        objectAnnotation.title = c.name
                        objectAnnotation.subtitle = c.id
                        self.mapView.layer.shadowColor = UIColor.clear.cgColor;
                        self.mapView.addAnnotation(objectAnnotation)
                    }
                }
                flag = true
            } else {
                let messageString: String = "Something wrong with the connection"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
                flag = false
            }
        }) 
        task.resume()
        // Download cinemas
        return flag
    }
    
    // Parse the received json result
    // solution from: https://github.com/SwiftyJSON/SwiftyJSON
    // and https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
    func parseCinemaJSON(_ movieJSON:Data){
        do{
            let result = try JSONSerialization.jsonObject(with: movieJSON,
                                                                    options: JSONSerialization.ReadingOptions.mutableContainers)
            let json = JSON(result)
            
            NSLog("Found \(json["results"].count) cinemas!")
            
        
            for cinema in json["results"].arrayValue {
                if let
                    latitude = cinema["geometry"]["location"]["lat"].double,
                    let longitude = cinema["geometry"]["location"]["lng"].double,
                    let name = cinema["name"].string,
                    let id = cinema["place_id"].string {
                    let c: Cinema = Cinema(latitude: latitude, longitude: longitude, name: name, id: id)
                    nearbyCinema.add(c)
                }
            }
        
        }catch {
            print("JSON Serialization error")
        }
    }
    
    // share the screenshot with external applications
    // solution from: https://www.hackingwithswift.com/example-code/uikit/how-to-share-content-with-uiactivityviewcontroller
    // and http://stackoverflow.com/questions/25448879/how-to-take-full-screen-screenshot-in-swift
    @IBAction func share(_ sender: UIBarButtonItem) {
        let layer = UIApplication.shared.keyWindow!.layer
        
        let scale = UIScreen.main.scale
        
        // get the screenshot of current view
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        
        self.present(activityViewController, animated: true, completion: nil)
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
