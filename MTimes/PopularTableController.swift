//
//  PopularTableController.swift
//  MTimes
//
//  Created by Dee on 10/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
import SwiftyJSON

class PopularTableController: UITableViewController {
    @IBOutlet var infoLabel: UILabel!
    
    var currentMovie: NSMutableArray
    required init?(coder aDecoder: NSCoder) {
        self.currentMovie = NSMutableArray()
        super.init(coder: aDecoder)
        
        // Define a NSMutableArray to store all reminders
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoLabel.text = "Loading movies..."
        
        self.downloadMovieData()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section)
        {
        case 0: return self.currentMovie.count
        case 1: return 1
        default: return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "MovieTableCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MovieTableCell
        
        // Configure the cell...
        let m: Movie = self.currentMovie[indexPath.row] as! Movie
        self.infoLabel.text = "Here Are " + String(currentMovie.count) + " Popular Movies"
        if (m.title != nil) {
            cell.titleLabel.text = m.title
        }
        if (m.popularity != nil) {
            cell.popularityLabel.text = "Popularity: " + String(format: "%.2f", m.popularity!)
        }
        if (m.rate != nil) {
            cell.rateLabel.text = "Rate: " + String(format: "%.2f", m.rate!)
        }
        if (m.date != nil) {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.stringFromDate(m.date!)
            cell.dateLabel.text = "Release Date: \(date)"
        }
        if (m.poster != nil) {
            let image = "http://image.tmdb.org/t/p/w500" + m.poster! + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
            if let url  = NSURL(string: image),
                data = NSData(contentsOfURL: url)
            {
                cell.posterView.image = UIImage(data: data)
            } else if (m.poster == "No Poster") {
                cell.posterView.image = UIImage(named: "Image")
            }
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0{
            return true
        }
        else{
            return false
        }
    }
    
    
    // Download current playing movies from the source and check network connection
    func downloadMovieData() {
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/popular?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4")!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let data = data {
                self.parseMovieJSON(data)
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
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
            
            NSLog("Found \(json["results"].count) new current playing movies!")
            for movie in json["results"].arrayValue {
                if let
                    id = movie["id"].int,
                    title = movie["title"].string,
                    overview = movie["overview"].string,
                    popularity = movie["popularity"].double,
                    rate = movie["vote_average"].double,
                    date = movie["release_date"].string,
                    count = movie["vote_count"].int{
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.timeZone = NSTimeZone(name: "UTC")
                    let release_date = dateFormatter.dateFromString(date)!
                    
                    if let
                        poster = movie["poster_path"].string,
                        backdrop = movie["backdrop_path"].string {
                        let m: Movie = Movie(id: id, title: title, poster: poster, overview: overview, popularity: popularity, rate: rate, date: release_date, count: count, backdrop: backdrop)
                        currentMovie.addObject(m)
                    } else {
                        let m: Movie = Movie(id: id, title: title, poster: "No Poster", overview: overview, popularity: popularity, rate: rate, date: release_date, count: count, backdrop: "No Image")
                        currentMovie.addObject(m)
                    }
                }
            }
        }catch {
            print("JSON Serialization error")
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "P_ViewMovieSegue"
        {
            let controller: MovieViewController = segue.destinationViewController as! MovieViewController
            
            let indexPath = tableView.indexPathForSelectedRow!
            
            let m: Movie = self.currentMovie[indexPath.row] as! Movie
            controller.currentMovie = m
            // Display movie details screen
        }
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
