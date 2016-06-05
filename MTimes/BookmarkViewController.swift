//
//  BookmarkViewController.swift
//  MTimes
//
//  Created by Dee on 3/06/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import SwiftyJSON

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    var currentMovie: Movie?
//    let mvc: MovieViewController = MovieViewController()
    var movies = MovieViewController().getMovies()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(self.refreshControl)
        
        if movies.count == 0 {
            self.infoLabel.text = "You haven't save any movie"
        } else {
            self.infoLabel.text = "Here are " + String(movies.count) + " Movies"
            self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        // Do some reloading of data and update the table view's data source
        // Fetch more objects from a web service, for example...
        
        // Simply adding an object to the data source for this example
        updateInfo()
        refreshControl.endRefreshing()
    }

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateInfo() {
        movies = MovieViewController().getMovies()
        self.tableView.reloadData()
        if movies.count == 0 {
            self.infoLabel.text = "You haven't save any movie"
        } else {
            self.infoLabel.text = "Here are " + String(movies.count) + " Movies"
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
        case 0: return self.movies.count
        case 1: return 1
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.backgroundColor = UIColor(red: 76/255.0, green: 76/255.0, blue: 76/255.0, alpha: 1.0)
        if movies.count != 0 {
            let title = self.movies[indexPath.row]["title"] as! String
            cell.textLabel?.backgroundColor = UIColor.clearColor()
            cell.textLabel?.font = UIFont.boldSystemFontOfSize(17)
            cell.textLabel?.textColor = UIColor.whiteColor()
            cell.textLabel?.text = title
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        //let indexPath = tableView.indexPathForSelectedRow!
        if movies.count != 0 {
            let id = self.movies[indexPath.row]["id"] as! Int
        
            let movieID = String(id) as String
        
            downloadMovieData(movieID)
        }
    }
    
    // Download current playing movies from the source and check network connection
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

        // Download movies
    }
    
    // Parse the received json result
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "B_ViewMovieSegue"
        {
            let controller: MovieViewController = segue.destinationViewController as! MovieViewController
            
            controller.currentMovie = currentMovie
            // Display movie details screen
        }
    }
}
