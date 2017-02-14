//
//  SearchTableController.swift
//  MTimes
//
//  Created by Dee on 11/05/2016.
//  Copyright © 2016 Dee. All rights reserved.
//

import UIKit
// external library from https://github.com/SwiftyJSON/SwiftyJSON
import SwiftyJSON

class SearchTableController: UITableViewController {
    @IBOutlet var infoLabel: UILabel!
    
    var m: Movie!
    var movieTitle: String?
    
    var currentMovie: NSMutableArray
    
    // Define a NSMutableArray to store all results
    required init?(coder aDecoder: NSCoder) {
        self.currentMovie = NSMutableArray()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.infoLabel.text = " Loading movies..."
        
        self.downloadMovieData()
        
        self.refreshControl?.addTarget(self, action: #selector(SearchTableController.refresh(_:)), for: UIControlEvents.valueChanged)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(_ sender:AnyObject)
    {
        // Updating table view data
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section)
        {
        case 0: return self.currentMovie.count
        case 1: return 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "MovieTableCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MovieTableCell
        
        // Configure the cell...
        let m: Movie = self.currentMovie[indexPath.row] as! Movie
        if currentMovie.count != 0 {
            self.infoLabel.text = " Here Are " + String(currentMovie.count) + " Results"
        }
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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.string(from: m.date! as Date)
            if (date != "1111-11-11") {
                cell.dateLabel.text = "Release Date: \(date)"
            } else {
                cell.dateLabel.text = "Release Date: Unknown"
            }
        }
        if (m.poster != nil) {
            let image = "http://image.tmdb.org/t/p/w500" + m.poster! + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4" as String
            if let url  = URL(string: image),
                let data = try? Data(contentsOf: url)
            {
                cell.posterView.image = UIImage(data: data)
            } else if (m.poster == "No Poster") {
                cell.posterView.image = UIImage(named: "Image")
            }
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0{
            return true
        }
        else{
            return false
        }
    }
    
    // Override to get selected movie
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let indexPath = tableView.indexPathForSelectedRow!
        
        m = self.currentMovie[indexPath.row] as! Movie
        
        self.performSegue(withIdentifier: "S_ViewMovieSegue", sender: nil)
    }
    
    // Download searching results from the source and check network connection
    // solution from: http://docs.themoviedb.apiary.io/#reference/search/searchmovie
    func downloadMovieData() {
        let mTitle = self.movieTitle!.replacingOccurrences(of: " ", with: "%20", options: NSString.CompareOptions.literal, range: nil)
        // solution from http://stackoverflow.com/questions/24551816/swift-encode-url
        let escapedString = mTitle.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = URL(string: "https://api.themoviedb.org/3/search/movie?query=" + escapedString!+"&api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data {
                self.parseMovieJSON(data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    if self.currentMovie.count == 0 {
                        self.infoLabel.text = "Sorry, No Result Found..."
                        let messageString: String = "No Result Found"
                        // Setup an alert to warn user
                        // UIAlertController manages an alert instance
                        let alertController = UIAlertController(title: "Sorry", message: messageString, preferredStyle: UIAlertControllerStyle.alert)
                        
                        alertController.addAction(UIAlertAction(title: "Try Again", style: UIAlertActionStyle.default,handler: nil))
                        
                        self.present(alertController, animated: true, completion: nil)
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
        // Download movies
    }
    
    // Parse the received json result
    // solution from: https://github.com/SwiftyJSON/SwiftyJSON
    // and https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
    func parseMovieJSON(_ movieJSON:Data){
        do{
            let result = try JSONSerialization.jsonObject(with: movieJSON,
                                                                    options: JSONSerialization.ReadingOptions.mutableContainers)
            let json = JSON(result)
            
            NSLog("Found \(json["results"].count) results!")
            
            for movie in json["results"].arrayValue {
                if let
                    id = movie["id"].int,
                    let title = movie["title"].string,
                    let overview = movie["overview"].string,
                    let popularity = movie["popularity"].double,
                    let rate = movie["vote_average"].double,
                    let date = movie["release_date"].string,
                    let count = movie["vote_count"].int {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    dateFormatter.timeZone = TimeZone(identifier: "UTC")
                    if date.characters.count == 0{
                        let release_date = dateFormatter.date(from: "1111-11-11")!
                    } else {
                    let release_date = dateFormatter.date(from: date)!
                    if let
                        poster = movie["poster_path"].string,
                        let backdrop = movie["backdrop_path"].string {
                        // Store the info in Movie ojbect
                        let m: Movie = Movie(id: id, title: title, poster: poster, overview: overview, popularity: popularity, rate: rate, date: release_date, count: count, backdrop: backdrop)
                        currentMovie.add(m)
                    } else {
                        // Some movies may not provide poster and images
                        let m: Movie = Movie(id: id, title: title, poster: "No Poster", overview: overview, popularity: popularity, rate: rate, date: release_date, count: count, backdrop: "No Image")
                        currentMovie.add(m)
                    }
                    }
                }
            }
        }catch {
            print("JSON Serialization error")
        }
    }
    
    // pass selected movie to movie detail screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "S_ViewMovieSegue"
        {
            let controller: MovieViewController = segue.destination as! MovieViewController
            
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
