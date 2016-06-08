//
//  BookmarkViewController.swift
//  MTimes
//
//  Created by Dee on 3/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
// external library from https://github.com/SwiftyJSON/SwiftyJSON
import SwiftyJSON

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    required init(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)!
    }
    
    var currentMovie: Movie?
    // get saved movies from MovieViewController
    var movies: [[String:AnyObject]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.addSubview(self.refreshControl)
        
        if MovieViewController().getMovies() == nil {
            self.infoLabel.text = "You haven't save any movie"
        } else {
            movies = MovieViewController().getMovies()
            self.infoLabel.text = "Here are " + String(movies!.count) + " Movies"
            self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // define refresh control for tableview
    // solution from: http://stackoverflow.com/questions/24475792/how-to-use-pull-to-refresh-in-swift
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(BookmarkViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // update the table view's data source
        updateInfo()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if movies != nil {
            updateInfo()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Update saved movies information in table view
    func updateInfo() {
        movies = MovieViewController().getMovies()
        self.tableView.reloadData()
        if movies!.count == 0 {
            self.infoLabel.text = "You haven't save any movie"
        } else {
            self.infoLabel.text = "Here are " + String(movies!.count) + " Movies"
            self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section)
        {
        case 0: return self.movies!.count
        case 1: return 1
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.backgroundColor = UIColor(red: 76/255.0, green: 76/255.0, blue: 76/255.0, alpha: 1.0)
        if movies!.count != 0 {
            let title = self.movies![indexPath.row]["title"] as! String
            cell.textLabel?.backgroundColor = UIColor.clearColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(17)
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.text = title
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if movies!.count != 0 {
            let id = self.movies![indexPath.row]["id"] as! Int
        
            let movieID = String(id) as String
        
            // get movie details for selected movie
            downloadMovieData(movieID)
        }
    }
    
    // Download selected movie from the source and check network connection
    // solution from: http://docs.themoviedb.apiary.io/#reference/movies
    func downloadMovieData(id: String) {
        let url = NSURL(string: "http://api.themoviedb.org/3/movie/" + id + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                self.parseMovieJSON(data)
                dispatch_async(dispatch_get_main_queue()) {
                    self.performSegueWithIdentifier("B_ViewMovieSegue", sender: nil)
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
        // Download movie
    }
    
    // Parse the received json result
    // solution from: https://github.com/SwiftyJSON/SwiftyJSON
    // and https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
    func parseMovieJSON(movieJSON:NSData){
        do{
            let result = try NSJSONSerialization.JSONObjectWithData(movieJSON,
                                                                    options: NSJSONReadingOptions.MutableContainers)
            let json = JSON(result)
            
            if let
                id = json["id"].int,
                title = json["title"].string,
                overview = json["overview"].string,
                popularity = json["popularity"].double,
                rate = json["vote_average"].double,
                date = json["release_date"].string,
                count = json["vote_count"].int{
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = NSTimeZone(name: "UTC")
                let release_date = dateFormatter.dateFromString(date)!
                
                if let
                    poster = json["poster_path"].string,
                    backdrop = json["backdrop_path"].string {
                    let m: Movie = Movie(id: id, title: title, poster: poster, overview: overview, popularity: popularity, rate: rate, date: release_date, count: count, backdrop: backdrop)
                    currentMovie = m
                } else {
                    let m: Movie = Movie(id: id, title: title, poster: "No Poster", overview: overview, popularity: popularity, rate: rate, date: release_date, count: count, backdrop: "No Image")
                    currentMovie = m
                }
            }
        }catch {
            print("JSON Serialization error")
        }
    }
    
    // pass movie object to movie detail screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "B_ViewMovieSegue"
        {
            let controller: MovieViewController = segue.destinationViewController as! MovieViewController
            
            controller.currentMovie = currentMovie
            // Display movie details screen
        }
    }
}
