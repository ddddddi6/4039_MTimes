//
//  CinemaViewController.swift
//  MTimes
//
//  Created by Dee on 23/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import SwiftyJSON
import MapKit

class CinemaViewController: UIViewController {

    @IBOutlet var cinemaPhoto: UIImageView!
    @IBOutlet var cinemaTitle: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var phoneNumber: UILabel!
    @IBOutlet var homepage: UILabel!
    @IBOutlet var address: UILabel!
    
    var currentCinemaID: String?
    
    var cinemaName: String?
    var cinemaPhone: String?
    var cinemaWeb: String?
    var cinemaAddress: String?
    var cinemaRating: Double?
    var photo: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadCinemaData()
        
        // add gesture to your Label
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CinemaViewController.handleTap(_:)))
        address.userInteractionEnabled=true
        address.addGestureRecognizer(tapGesture)
        
        let tapGesture_p = UITapGestureRecognizer(target: self, action: #selector(CinemaViewController.webView(_:)))
        homepage.userInteractionEnabled=true
        homepage.addGestureRecognizer(tapGesture_p)

        
        // Do any additional setup after loading the view.
    }
    
    func webView(sender:UITapGestureRecognizer){
        self.performSegueWithIdentifier("CinemaWebSegue", sender: nil)
    }
    
    // handle the function of UILabel
    func handleTap(sender:UITapGestureRecognizer) -> Bool{
        var flag = true as Bool
            let geocoder = CLGeocoder()
            let str = address.text // A string of the address info you already have
            geocoder.geocodeAddressString(str!) { (placemarksOptional, error) -> Void in
                if let placemarks = placemarksOptional {
                    print("placemark| \(placemarks.first)")
                    if let location = placemarks.first?.location {
                        let query = "?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)"
                        let path = "http://maps.apple.com/" + query
                        if let url = NSURL(string: path) {
                            UIApplication.sharedApplication().openURL(url)
                        } else {
                            flag = false
                            // Could not construct url. Handle error.
                        }
                    } else {
                        flag = false
                        // Could not get a location from the geocode request. Handle error.
                    }
                } else {
                    flag = false
                    // Didn't get any placemarks. Handle error.
                }
            }
        return flag
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Download current playing movies from the source and check network connection
    func downloadCinemaData() {
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + currentCinemaID! + "&key=AIzaSyBpHKu9KGpv-VacWvQOhrI7OVjGVdHQY9Y")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                self.parseCinemaJSON(data)
                dispatch_async(dispatch_get_main_queue()) {
                    self.title = self.cinemaName
                    self.address.text = self.cinemaAddress
                    self.homepage.text = self.cinemaWeb
                    self.phoneNumber.text = self.cinemaPhone
                    self.rating.text = "Rating: " + String(format: "%.1f", self.cinemaRating!)
                    let poster = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + self.photo! + "&key=AIzaSyBpHKu9KGpv-VacWvQOhrI7OVjGVdHQY9Y" as String
                    if let url  = NSURL(string: poster),
                        data = NSData(contentsOfURL: url)
                    {
                        self.cinemaPhoto.image = UIImage(data: data)
                    } else {
                        self.cinemaPhoto.image = UIImage(named: "Image")
                    }

                }
            } else {
                let messageString: String = "Something wrong with the connection"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        task.resume()
        // Download movies
    }
    
    // Parse the received json result
    func parseCinemaJSON(movieJSON:NSData){
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            //NSLog("Found \(json["result"].count) new current playing movies!")

            if let
                name = json["result"]["name"].string,
                phone = json["result"]["international_phone_number"].string,
                website = json["result"]["website"].string,
                address = json["result"]["vicinity"].string,
                photo = json["result"]["photos"][0]["photo_reference"].string,
                rating = json["result"]["rating"].double{
                    self.cinemaName = name
                    self.cinemaPhone = phone
                    self.cinemaWeb = website
                    self.cinemaAddress = address
                    self.cinemaRating = rating
                    self.photo = photo
                }
            
        
        }catch {
            print("JSON Serialization error")
        }
    }

    

    @IBAction func share(sender: UIBarButtonItem) {
        let bounds = UIScreen.mainScreen().bounds
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
        
        self.view.drawViewHierarchyInRect(bounds, afterScreenUpdates: false)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        
        self.presentViewController(activityViewController, animated: true, completion: nil)

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CinemaWebSegue"
        {
            
            let controller: WebViewController = segue.destinationViewController as! WebViewController
            controller.weblink = self.homepage.text
            // Display movie details screen
        }
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
