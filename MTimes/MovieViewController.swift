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
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var posterView: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var popularityLabel: UILabel!
    @IBOutlet var rateLabel: UILabel!
    @IBOutlet var overviewLabel: UILabel!
    @IBOutlet var similar: UILabel!
    @IBOutlet var imagesView: UIScrollView!
    
    
    var currentMovie: Movie?
    var movieSet = [String]()
    var imageSet = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlStrings = ["https://api.themoviedb.org/3/movie/" + String(self.currentMovie!.id!) + "/images?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4",
                          "https://api.themoviedb.org/3/movie/" + String(self.currentMovie!.id!) + "/similar?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4"]
        
        for var i = 0; i < urlStrings.count; i++
        {
            downloadMovieData(urlStrings[i], flag: i)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scrollView.contentSize.height = 3000
        
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
        self.imagesView.frame.size.width = UIScreen.mainScreen().bounds.width
        self.imagesView.frame.size.height = UIScreen.mainScreen().bounds.width / 1.5
        
        // Display selected movie details
    }
    
    // Download current playing movies from the source and check network connection
    func downloadMovieData(url: String, flag: Int) -> Bool {
        var flags = true as Bool
        let url = NSURL(string: url)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                self.parseMovieJSON(data)
                dispatch_async(dispatch_get_main_queue()) {
                    if flag == 0 {
                        self.updateImages()
                    } else if flag == 1 {
                        self.updateSimilarMovies()
                    }
                }
                flags = true
            } else {
                let messageString: String = "Something wrong with the network connection"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                flags = false
            }
        }
        task.resume()
        return flags
        // Download movies
    }
    
    // Parse the received json result
    func parseMovieJSON(movieJSON:NSData) -> Bool{
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            if json["results"].count != 0 {
                NSLog("Found \(json["results"].count) similar movies!")
                for movie in json["results"].arrayValue {
                    if let title = movie["title"].string {
                        movieSet.append(title)
                    }
                }
            } else if json["backdrops"] != 0 {
                NSLog("Found \(json["backdrops"].count) images!")
                for image in json["backdrops"].arrayValue {
                        if let path = image["file_path"].string {
                            imageSet.append(path)
                        }
                }
            }
        }catch {
            print("JSON Serialization error")
        }
        return true
    }
    
    func updateSimilarMovies() -> Bool {
        if self.movieSet.count != 0 {
            self.similar.text = "Similar Movies"
            var number = self.similar.frame.maxY + 5
            for var i = 0; i < self.movieSet.count; i++
            {
                let label = UILabel(frame: CGRectMake(23, number , 380, 21))
                label.text = self.movieSet[i]
                label.textColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.7)
                label.font = UIFont.boldSystemFontOfSize(11)
                self.scrollView.addSubview(label)
                number += 15
                self.scrollView.contentSize.height += 15
            }
        } else {
            self.similar.text = " "
            self.similar.enabled = false
            self.scrollView.contentSize.height = self.similar.frame.maxY + 10
        }
        
        let button = UIButton(frame: CGRectMake(100, scrollView.contentSize.height + 15 , 150, 28))
        button.center.x = self.scrollView.center.x
        button.backgroundColor = UIColor.grayColor()
        button.layer.cornerRadius = 5.0
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        button.setTitle("Find a Cinema", forState: UIControlState.Normal)
        self.scrollView.addSubview(button)
        self.scrollView.contentSize.height = button.frame.maxY + 10
        
        button.addTarget(self, action: #selector(MovieViewController.buttonAction(_:)), forControlEvents: .TouchUpInside)
        return true
    }
    
    func updateImages() {
        if imageSet.count != 0 {
        
            let image1 = "http://image.tmdb.org/t/p/w500" + self.imageSet[0] + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
            let imageView1 = UIImageView(frame: CGRectMake(0, 0, self.imagesView.frame.width, self.imagesView.frame.height))
            let imageView2 = UIImageView(frame: CGRectMake(self.imagesView.frame.width, 0, self.imagesView.frame.width, self.imagesView.frame.height))
        
            if let url  = NSURL(string: image1),
                data = NSData(contentsOfURL: url) {
                    imageView1.image = UIImage(data: data)
                } else {
                    imageView1.image = UIImage(named: "noimage")
                }
            
            let image2 = "http://image.tmdb.org/t/p/w500" + self.imageSet[imageSet.count - 1] + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
        
            if let url  = NSURL(string: image2),
                data = NSData(contentsOfURL: url) {
                    imageView2.image = UIImage(data: data)
                } else {
                    imageView2.image = UIImage(named: "noimage")
                }
            self.imagesView.addSubview(imageView1)
            self.imagesView.addSubview(imageView2)
            imagesView.contentSize = CGSizeMake(imagesView.frame.size.width*2, imagesView.frame.size.height)
        } else {
            let imageView1 = UIImageView(frame: CGRectMake(0, 0, self.imagesView.frame.width, self.imagesView.frame.height))
            imageView1.image = UIImage(named: "noimage")
            self.imagesView.addSubview(imageView1)
        }
    }
    
    func buttonAction (sender: UIButton!) {
        self.performSegueWithIdentifier("CinemaMapSegue", sender: nil)
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
