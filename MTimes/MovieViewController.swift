//
//  MovieViewController.swift
//  MTimes
//
//  Created by Dee on 4/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import SwiftyJSON

class MovieViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var overview: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var posterView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var popularityLabel: UILabel!
    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var similar: UILabel!
    
    
    var currentMovie: Movie?
    var movieSet = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadMovieData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scrollView.contentSize.height = 1000
        
        self.overview.text = "Overview"
        
        self.titleLabel.text = self.currentMovie!.title
        self.popularityLabel.text = "Popularity: " + String(format: "%.2f", currentMovie!.popularity!)
        self.rateLabel.text = "Rate: " + String(format: "%.2f", currentMovie!.rate!) + "/" + String(currentMovie!.count!) + " votes"
        self.overviewLabel.text = currentMovie!.overview
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.stringFromDate(currentMovie!.date!)
        self.dateLabel.text = "Release Date: \(date)"
        let poster = "http://image.tmdb.org/t/p/w500" + currentMovie!.poster! + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
        if let url  = NSURL(string: poster),
            data = NSData(contentsOfURL: url)
        {
            self.posterView.image = UIImage(data: data)
        } else {
            self.posterView.image = UIImage(named: "Image")
        }
        let image = "http://image.tmdb.org/t/p/w1000" + currentMovie!.backdrop! + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
        if let url  = NSURL(string: image),
            data = NSData(contentsOfURL: url)
        {
            self.imageView.image = UIImage(data: data)
        } else {
            self.imageView.image = UIImage(named: "Image")
        }
        // Display selected movie details
    }
    
    // Download current playing movies from the source and check network connection
    func downloadMovieData() {
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/" + String(self.currentMovie!.id!) + "/similar?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                self.parseMovieJSON(data)
                dispatch_async(dispatch_get_main_queue()) {
                    if self.movieSet.count != 0 {
                        self.similar.text = "Similar Movies"
                    } else {
                        self.similar.text = ""
                    }
                    var number = self.similar.frame.maxY + 5
                    for var i = 1; i < self.movieSet.count; i++
                    {
                        let label = UILabel(frame: CGRectMake(23, number , 380, 21))
                        label.text = self.movieSet[i]
                        label.textColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.7)
                        label.font = UIFont.boldSystemFontOfSize(13)
                        self.scrollView.addSubview(label)
                        number += 15
                        self.scrollView.contentSize.height += 15
                    }
                    let button = UIButton(frame: CGRectMake(100, number + 15 , 150, 28))
                    button.center.x = self.scrollView.center.x
                    button.backgroundColor = UIColor.grayColor()
                    button.layer.cornerRadius = 5.0
                    button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    button.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
                    button.setTitle("Find a Cinema", forState: UIControlState.Normal)
                    self.scrollView.addSubview(button)
                    self.scrollView.contentSize.height += 30
//                    self.imageView1 = UIImageView(frame:CGRectMake(0, 0, self.scrollView.frame.width, self.scrollView.frame.height))
//                    let image1 = "http://image.tmdb.org/t/p/w500" + self.imageSet[0] + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
//                    
//                    if let url  = NSURL(string: image1),
//                        data = NSData(contentsOfURL: url)
//                    {
//                        self.imageView1!.image = UIImage(data: data)
//                    } else {
//                        self.imageView1!.image = UIImage(named: "Image")
//                    }
//                    self.scrollView.addSubview(self.imageView1!)
//                    
//                    self.imageView2 = UIImageView(frame:CGRectMake(0, 0, self.scrollView.frame.width, self.scrollView.frame.height))
//                    let image2 = "http://image.tmdb.org/t/p/w500" + self.imageSet[1] + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
//                    
//                    if let url  = NSURL(string: image2),
//                        data = NSData(contentsOfURL: url)
//                    {
//                        self.imageView2!.image = UIImage(data: data)
//                    } else {
//                        self.imageView2!.image = UIImage(named: "Image")
//                    }
//                    self.scrollView.addSubview(self.imageView2!)
                }
            } else {
                let messageString: String = "Something wrong with the network connection"
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
    func parseMovieJSON(movieJSON:NSData){
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            NSLog("Found \(json["results"].count) similar movies!")
            for movie in json["results"].arrayValue {
                if let title = movie["title"].string {
                    movieSet.append(title)
                }
            }
        }catch {
            print("JSON Serialization error")
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
