//
//  CinemaViewController.swift
//  MTimes
//
//  Created by Dee on 23/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
// external library from https://github.com/SwiftyJSON/SwiftyJSON
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
    
    var link: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        downloadCinemaData()
        
        // add gesture to Labels
        let tapGesture_c = UITapGestureRecognizer(target: self, action: #selector(CinemaViewController.callNumber(_:)))
        phoneNumber.isUserInteractionEnabled=true
        phoneNumber.addGestureRecognizer(tapGesture_c)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CinemaViewController.navigateCinema(_:)))
        address.isUserInteractionEnabled=true
        address.addGestureRecognizer(tapGesture)
        
        let tapGesture_p = UITapGestureRecognizer(target: self, action: #selector(CinemaViewController.webView(_:)))
        homepage.isUserInteractionEnabled=true
        homepage.addGestureRecognizer(tapGesture_p)
        
        // Do any additional setup after loading the view.
    }
    
    // jump to cinema homepage
    func webView(_ sender:UITapGestureRecognizer){
        link = self.homepage.text
        self.performSegue(withIdentifier: "CinemaWebSegue", sender: nil)
    }
    
    // call cinema phone number
    func callNumber(_ sender:UITapGestureRecognizer) {
        let number = self.phoneNumber.text!.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
        if let phoneCallURL:URL = URL(string:"tel://\(number)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    // open the map in map application
    func navigateCinema(_ sender:UITapGestureRecognizer) -> Bool{
        var flag = true as Bool
            let geocoder = CLGeocoder()
            let str = address.text // A string of the address info you already have
            geocoder.geocodeAddressString(str!) { (placemarksOptional, error) -> Void in
                if let placemarks = placemarksOptional {
                    print("placemark| \(placemarks.first)")
                    if let location = placemarks.first?.location {
                        let query = "?ll=\(location.coordinate.latitude),\(location.coordinate.longitude)"
                        let path = "http://maps.apple.com/" + query
                        if let url = URL(string: path) {
                            UIApplication.shared.openURL(url)
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
    
    // Download selected cinema from the source and check network connection
    func downloadCinemaData() {
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=" + currentCinemaID! + "&key=AIzaSyBpHKu9KGpv-VacWvQOhrI7OVjGVdHQY9Y")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data {
                self.parseCinemaJSON(data)
                DispatchQueue.main.async {
                    self.title = self.cinemaName
                    self.address.text = self.cinemaAddress
                    self.homepage.text = self.cinemaWeb
                    self.phoneNumber.text = self.cinemaPhone
                    self.rating.text = "Rating: " + String(format: "%.1f", self.cinemaRating!)
                    let poster = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=" + self.photo! + "&key=AIzaSyBpHKu9KGpv-VacWvQOhrI7OVjGVdHQY9Y" as String
                    if let url  = URL(string: poster),
                        let data = try? Data(contentsOf: url)
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
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }) 
        task.resume()
        // Download cinema
    }
    
    // Parse the received json result
    // solution from: https://github.com/SwiftyJSON/SwiftyJSON
    // and https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
    func parseCinemaJSON(_ movieJSON:Data){
        do{
            let result = try JSONSerialization.jsonObject(with: movieJSON,
                                                                    options: JSONSerialization.ReadingOptions.mutableContainers)
            let json = JSON(result)

            if let
                name = json["result"]["name"].string,
                let phone = json["result"]["international_phone_number"].string,
                let website = json["result"]["website"].string,
                let address = json["result"]["vicinity"].string,
                let photo = json["result"]["photos"][0]["photo_reference"].string,
                let rating = json["result"]["rating"].double{
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
    
    // pass homepage link to web view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CinemaWebSegue"
        {
            let controller: WebViewController = segue.destination as! WebViewController
            controller.weblink = link
            // Go to cinema homepage
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
