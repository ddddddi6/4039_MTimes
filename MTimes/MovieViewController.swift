//
//  MovieViewController.swift
//  MTimes
//
//  Created by Dee on 4/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
// external library from https://github.com/SwiftyJSON/SwiftyJSON
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
    
    var myDefaults = UserDefaults.standard
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (self.currentMovie?.id != nil){
            let apiLink = "https://api.themoviedb.org/3/movie/" + String(self.currentMovie!.id!) as String
            let apiKey = "api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4"

            let urlStrings = [apiLink + "/images?" + apiKey,
                          apiLink + "/similar?" + apiKey,
                          apiLink + "/videos?" + apiKey,
                          apiLink + "/reviews?" + apiKey]
        
            // download movie detail from each api link
            for i in 0 ..< urlStrings.count
            {
                downloadMovieData(urlStrings[i], flag: i)
            }
        }
            // check whether the movie has been saved
        let key = myDefaults.object(forKey: "savedMovie")
            if (key != nil) {
                if (checkMarked()){
                    // update UI if the movie has been saved
                button?.backgroundColor = UIColor(red: 55/255.0, green: 187.0/255.0, blue: 38.0/255.0, alpha: 1.0)
                button.setTitle("Remove Bookmark", for: UIControlState())
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
                }
            }
        
            button.addTarget(self, action: #selector(MovieViewController.markMovie(_:)), for: .touchUpInside)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.scrollView.contentSize.height = 3000
        
        self.overview.text = "Overview"
        
        self.titleLabel.text = "" + self.currentMovie!.title!
        self.popularityLabel.text = "Popularity: " + String(format: "%.2f", currentMovie!.popularity!)
        self.rateLabel.text = "Rate: " + String(format: "%.2f", currentMovie!.rate!) + "/" + String(currentMovie!.count!) + " votes"
        self.overviewLabel.text = currentMovie!.overview
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: currentMovie!.date! as Date)
        self.dateLabel.text = "Release Date: \(date)"
        let poster = "http://image.tmdb.org/t/p/w500" + currentMovie!.poster! + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
        if let url  = URL(string: poster),
            let data = try? Data(contentsOf: url)
        {
            self.posterView.image = UIImage(data: data)
        } else {
            self.posterView.image = UIImage(named: "Image")
        }
        self.imagesView.frame.size.width = UIScreen.main.bounds.width
        self.imagesView.frame.size.height = UIScreen.main.bounds.width / 1.5
        
        // Display selected movie details
    }
    
    // Download selected movie from the source and check network connection
    // solution from: http://docs.themoviedb.apiary.io
    func downloadMovieData(_ url: String, flag: Int) {
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let priority = DispatchQoS.QoSClass.userInteractive
        DispatchQueue.global(qos: priority).async {
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data {
                // parse json result
                switch (flag) {
                case 0:
                    self.parsePosterJSON(data)
                    DispatchQueue.main.async {
                        self.updateImages()
                    }
                    break
                case 1:
                    self.parseSimilarMovieJSON(data)
                    DispatchQueue.main.async {
                        self.updateSimilarMovies()
                    }
                    break
                case 2:
                    self.parseVideoJSON(data)
                    DispatchQueue.main.async {
                        self.updateVideo()
                    }
                    break
                case 3:
                    self.parseReviewJSON(data)
                    DispatchQueue.main.async {
                        self.updateReview()
                    }
                    break
                default:
                    break
                }
            } else {
                let messageString: String = "Something wrong with the network connection"
                // Setup an alert to warn user
                // UIAlertController manages an alert instance
                let alertController = UIAlertController(title: "Alert", message: messageString, preferredStyle: UIAlertControllerStyle.alert)
                
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
                
                self.present(alertController, animated: true, completion: nil)
            }
        }) 
        task.resume()
        }
        // Download movie
    }
    
    // Parse the received json result for backdrops
    // solution from: https://github.com/SwiftyJSON/SwiftyJSON
    // and https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
    func parsePosterJSON(_ movieJSON:Data) -> Bool{
        do{
            let result = try JSONSerialization.jsonObject(with: movieJSON,
                                                                    options: JSONSerialization.ReadingOptions.mutableContainers)
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
    
    // Display backdrops of the movie
    func updateImages() {
        if imageSet.count != 0 {
            let image1 = "http://image.tmdb.org/t/p/w500" + self.imageSet[0] + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
            let imageView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: self.imagesView.frame.width, height: self.imagesView.frame.height))
            let imageView2 = UIImageView(frame: CGRect(x: self.imagesView.frame.width, y: 0, width: self.imagesView.frame.width, height: self.imagesView.frame.height))
        
            if let url  = URL(string: image1),
                let data = try? Data(contentsOf: url) {
                    imageView1.image = UIImage(data: data)
                } else {
                    imageView1.image = UIImage(named: "noimage")
                }
            
            let image2 = "http://image.tmdb.org/t/p/w500" + self.imageSet[imageSet.count - 1] + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
        
            if let url  = URL(string: image2),
                let data = try? Data(contentsOf: url) {
                    imageView2.image = UIImage(data: data)
                } else {
                    imageView2.image = UIImage(named: "noimage")
                }
            self.imagesView.addSubview(imageView1)
            self.imagesView.addSubview(imageView2)
            imagesView.contentSize = CGSize(width: imagesView.frame.size.width*2, height: imagesView.frame.size.height)
        } else {
            let imageView1 = UIImageView(frame: CGRect(x: 0, y: 0, width: self.imagesView.frame.width, height: self.imagesView.frame.height))
            imageView1.image = UIImage(named: "noimage")
            self.imagesView.addSubview(imageView1)
        }
    }
    
    // Parse the received json result for similar movies
    func parseSimilarMovieJSON(_ movieJSON:Data) -> Bool{
        var flag = true as Bool
        do{
            let result = try JSONSerialization.jsonObject(with: movieJSON,
                                                                    options: JSONSerialization.ReadingOptions.mutableContainers)
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
            flag = false
            print("JSON Serialization error")
        }
        return flag
    }
    
    // display similar movies on screen
    func updateSimilarMovies() -> Bool {
        if self.movieSet.count >= 5 {
            self.similar.text = "Similar Movies"
            self.similar.backgroundColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
            var number = self.similar.frame.maxY + 5
            for i in 0 ..< 5
            {
                let label = UILabel(frame: CGRect(x: 23, y: number , width: 380, height: 21))
                label.text = self.movieSet[i]
                label.textColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 0.7)
                label.font = UIFont.boldSystemFont(ofSize: 11)
                self.scrollView.addSubview(label)
                number += 15
                self.scrollView.contentSize.height += 8
            }
        } else {
            self.similar.text = " "
            self.similar.isEnabled = false
            self.scrollView.contentSize.height = self.similar.frame.maxY
        }
        return true
    }
    
    // Parse the received json result for videos
    func parseVideoJSON(_ movieJSON:Data) {
        do{
            let result = try JSONSerialization.jsonObject(with: movieJSON,
                                                                    options: JSONSerialization.ReadingOptions.mutableContainers)
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

    // embed youtube video
    // solution from: https://www.youtube.com/watch?v=5qwyoi3sQPI
    func updateVideo() {
        if self.videoKey != nil {
            let webV:UIWebView = UIWebView(frame: CGRect(x: 0, y: scrollView.contentSize.height+25, width: UIScreen.main.bounds.width, height: 230))
            webV.backgroundColor = UIColor.clear
            webV.scrollView.showsHorizontalScrollIndicator = false
            webV.scrollView.showsVerticalScrollIndicator = false
        
            let height = webV.frame.height - 20
        
            let youtubelink: String = "https://www.youtube.com/embed/" + self.videoKey!
            let Code: NSString = "<body style='background-color: #4C4C4C; margin: 0; padding: 0;'><iframe width=100% height=\(height) src=\(youtubelink) frameborder=0  allowfullscreen></iframe></body>" as NSString
            webV.loadHTMLString(Code as String, baseURL: nil)
        
            self.scrollView.addSubview(webV)
            self.scrollView.contentSize.height = webV.frame.maxY + 5
        }
        else {
            self.scrollView.contentSize.height += 5
        }
    }
    
    // Parse the received json result for reviews
    func parseReviewJSON(_ movieJSON:Data) {
        do{
            let result = try JSONSerialization.jsonObject(with: movieJSON,
                                                                    options: JSONSerialization.ReadingOptions.mutableContainers)
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
    
    // display reviews of current movie
    func updateReview() {
        if reviews.count != 0 {
            let review = UILabel(frame: CGRect(x: 8, y: scrollView.contentSize.height,  width: UIScreen.main.bounds.width - 16, height: 21))
            review.text = "Reviews"
            review.textColor = UIColor.white
            review.font = UIFont.boldSystemFont(ofSize: 17)
            review.backgroundColor = UIColor(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
            self.scrollView.addSubview(review)
            var number = review.frame.maxY + 5
            for i in 0 ..< self.reviews.count
            {
                let label = UILabel(frame: CGRect(x: 23, y: number , width: 330, height: 62))
                label.lineBreakMode = NSLineBreakMode.byWordWrapping
                label.numberOfLines = 3
                label.text = self.reviews[i]
                label.textColor = UIColor.white
                label.font = UIFont.systemFont(ofSize: 12)
                self.scrollView.addSubview(label)
                number = label.frame.maxY + 5
                self.scrollView.contentSize.height = label.frame.maxY + 5
            }
             self.scrollView.contentSize.height += 10
        } else {
            self.scrollView.contentSize.height += 5
        }
    }
    
    // save or mark the movie in `NSUserDefaults`
    // solution from: https://www.hackingwithswift.com/read/12/2/reading-and-writing-basics-nsuserdefaults
    // and http://stackoverflow.com/questions/26233067/simple-persistent-storage-in-swift
    func markMovie(_ sender: UIButton!) {
        
        // Check whether the `NSUserDefaults` exists and the movie has been saved, then update UI
        
        if (myDefaults.object(forKey: "savedMovie") == nil) {
            // the savedMovie `NSUserDefaults` does not exist
            
            let array = [["id": currentMovie!.id!, "title": currentMovie!.title!]]             
            // then update whats in the `NSUserDefault`
            myDefaults.set(array, forKey: "savedMovie")
            
            // call this after update
            myDefaults.synchronize()
            
            // update UI
            button.setTitle("Remove Bookmark", for: UIControlState())
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button?.backgroundColor = UIColor(red: 55/255.0, green: 187.0/255.0, blue: 38.0/255.0, alpha: 1.0)

        } else {
            // the movie has not been saved
            
            if !checkMarked() {
            var array = getMovies()
            
            // add movie id and title
            array!.append(["id": currentMovie!.id! as AnyObject, "title": currentMovie!.title! as AnyObject])
            
            // then update whats in the `NSUserDefault`
            myDefaults.set(array, forKey: "savedMovie")
                
            // call this after update
            myDefaults.synchronize()
            
            // update UI
            button.setTitle("Remove Bookmark", for: UIControlState())
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            button?.backgroundColor = UIColor(red: 55/255.0, green: 187.0/255.0, blue: 38.0/255.0, alpha: 1.0)
        } else {
            // remove mark from this movie and delete from `NSUserDefaults`
                
            var array = getMovies()
            var index = -1 as Int
            for i in (0..<array!.count+1) {
                let id = array![i]["id"] as! Int
                if currentMovie?.id == id {
                    index = i
                    break
                }
            }
            array!.remove(at: index)
            // then update whats in the `NSUserDefault`
            myDefaults.set(array, forKey: "savedMovie")
            
            // call this after update
            myDefaults.synchronize()
            button.setTitle("Bookmark", for: UIControlState())
            button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            button?.backgroundColor = UIColor(red: 127/255.0, green: 127.0/255.0, blue: 127.0/255.0, alpha: 1.0)
        }
        }
    }
    
    // return saved movies
    func getMovies() -> [[String:AnyObject]]? {
        let movies = myDefaults.object(forKey: "savedMovie") as? [[String:AnyObject]]
        return movies
    }
    
    // check the marking status of this movie
    func checkMarked () -> Bool {
        let movies = getMovies()
        var flag = false
        for movie in movies! {
            let id = movie["id"] as! Int
            if currentMovie?.id == id {
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
