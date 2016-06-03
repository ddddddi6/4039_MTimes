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

    @IBOutlet var button: UIButton!
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
    var videoKey: String?
    var reviews = [String]()
    
    let myDefaults = NSUserDefaults.standardUserDefaults()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let apiLink = "https://api.themoviedb.org/3/movie/" + String(self.currentMovie!.id!) as String
        let apiKey = "api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4"

        
        let urlStrings = [apiLink + "/images?" + apiKey,
                          apiLink + "/similar?" + apiKey,
                          apiLink + "/videos?" + apiKey,
                          apiLink + "/reviews?" + apiKey]
        
        for i in 0 ..< urlStrings.count
        {
            downloadMovieData(urlStrings[i], flag: i)
        }
        
        if (checkMarked()) {
            button?.backgroundColor = UIColor(red: 0/255.0, green: 128.0/255.0, blue: 64.0/255.0, alpha: 1.0)
            button.setTitle("Bookmarked", forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont.boldSystemFontOfSize(12)
        }
        
        button.addTarget(self, action: #selector(MovieViewController.bookMovie(_:)), forControlEvents: .TouchUpInside)
        
        
        //downloadVideoData()

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
        let priority = QOS_CLASS_USER_INTERACTIVE
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                switch (flag) {
                case 0:
                    self.parsePosterJSON(data)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updateImages()
                    }
                    break
                case 1:
                    self.parseMovieJSON(data)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updateSimilarMovies()
                    }
                    break
                case 2:
                    self.parseVideoJSON(data)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updateVideo()
                    }
                    break
                case 3:
                    self.parseReviewJSON(data)
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updateReview()
                    }
                    break
                default:
                    break
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
        }
        return flags
        // Download movies
    }
    
    // Parse the received json result
    func parsePosterJSON(movieJSON:NSData) -> Bool{
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            if json["backdrops"] != 0 {
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
            }
        }catch {
            print("JSON Serialization error")
        }
        return true
    }
    
    func updateSimilarMovies() -> Bool {
        if self.movieSet.count >= 5 {
            self.similar.text = "Similar Movies"
            self.similar.backgroundColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
            var number = self.similar.frame.maxY + 5
            for var i = 0; i < 5; i++
            {
                let label = UILabel(frame: CGRectMake(23, number , 380, 21))
                label.text = self.movieSet[i]
                label.textColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.7)
                label.font = UIFont.boldSystemFontOfSize(11)
                self.scrollView.addSubview(label)
                number += 15
                self.scrollView.contentSize.height += 8
            }
        } else {
            self.similar.text = " "
            self.similar.enabled = false
            self.scrollView.contentSize.height = self.similar.frame.maxY
        }
        return true
    }
    
    // Parse the received json result
    func parseVideoJSON(movieJSON:NSData) {
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            if json["results"].count != 0 {
                NSLog("Found \(json["results"].count) videos!")
                    if let key = json["results"][0]["key"].string {
                        self.videoKey = key
                }
            }
        }catch {
            print("JSON Serialization error")
        }
    }

    func updateVideo() {
        if self.videoKey != nil {
            let webV:UIWebView = UIWebView(frame: CGRectMake(0, scrollView.contentSize.height+25, UIScreen.mainScreen().bounds.width, 230))
            webV.backgroundColor = UIColor.clearColor()
            webV.scrollView.showsHorizontalScrollIndicator = false
            webV.scrollView.showsVerticalScrollIndicator = false
        
            let height = webV.frame.height - 20
        
            let youtubelink: String = "https://www.youtube.com/embed/" + self.videoKey!
            let Code: NSString = "<body style='background-color: #4C4C4C; margin: 0; padding: 0;'><iframe width=100% height=\(height) src=\(youtubelink) frameborder=0  allowfullscreen></iframe></body>"
            webV.loadHTMLString(Code as String, baseURL: nil)
        
            self.scrollView.addSubview(webV)
            self.scrollView.contentSize.height = webV.frame.maxY + 5
        }
        else {
            self.scrollView.contentSize.height += 5
        }
    }
    
    // Parse the received json result
    func parseReviewJSON(movieJSON:NSData) {
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            if json["results"].count != 0 {
                NSLog("Found \(json["results"].count) reviews!")
                for review in json["results"].arrayValue {
                    if let content = review["content"].string {
                        self.reviews.append(content)
                    }
                }
            }
        }catch {
            print("JSON Serialization error")
        }
    }
    
    func updateReview() {
        if reviews.count != 0 {
            let review = UILabel(frame: CGRectMake(8, scrollView.contentSize.height,  UIScreen.mainScreen().bounds.width - 16, 21))
            review.text = "Reviews"
            review.textColor = UIColor.whiteColor()
            review.font = UIFont.boldSystemFontOfSize(17)
            review.backgroundColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
            self.scrollView.addSubview(review)
            var number = review.frame.maxY + 5
            for var i = 0; i < self.reviews.count; i++
            {
                let label = UILabel(frame: CGRectMake(23, number , 330, 62))
                label.lineBreakMode = NSLineBreakMode.ByWordWrapping
                label.numberOfLines = 3
                label.text = self.reviews[i]
                label.textColor = UIColor.whiteColor()
                label.font = UIFont.systemFontOfSize(12)
                self.scrollView.addSubview(label)
                number = label.frame.maxY + 5
                self.scrollView.contentSize.height = label.frame.maxY + 5
            }
             self.scrollView.contentSize.height += 10
        } else {
            self.scrollView.contentSize.height += 5
        }
    }
    
    func bookMovie(sender: UIButton) {
        //myDefaults.setObject(currentMovie?.title, forKey: "myMovie")
        let flag = checkMarked()
        
            if !flag {
                var storedData = myDefaults.objectForKey("myMovie") as? [String] ?? [String]()
                
                storedData.append((currentMovie?.title)!)
                
                // then update whats in the `NSUserDefault`
                myDefaults.setObject(storedData, forKey: "myMovie")
                
                // call this after you update
                myDefaults.synchronize()
                button!.titleLabel?.text = "Bookmarked"
                button?.backgroundColor = UIColor(red: 0/255.0, green: 128.0/255.0, blue: 64.0/255.0, alpha: 1.0)
                button!.titleLabel?.font = UIFont.boldSystemFontOfSize(12)
            } else {
                let messageString: String = "You have already saved this movie"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle: UIAlertControllerStyle.Alert)
                
                alertController.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
    }
    
    func getMovies() -> [String] {
        let array = myDefaults.objectForKey("myMovie") as? [String] ?? [String]()
        return array
    }
    
    func checkMarked () -> Bool {
        let array = getMovies()
        var flag = false
        for movie in array {
            if currentMovie?.title == movie {
                flag = true
                break
            }
        }
        return flag
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
