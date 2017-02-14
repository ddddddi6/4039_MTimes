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
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.addSubview(self.refreshControl)
        
        if MovieViewController().getMovies() == nil {
            self.infoLabel.text = "You haven't save any movie"
        } else {
            movies = MovieViewController().getMovies()
            self.infoLabel.text = "Here are " + String(movies!.count) + " Movies"
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    // define refresh control for tableview
    // solution from: http://stackoverflow.com/questions/24475792/how-to-use-pull-to-refresh-in-swift
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(BookmarkViewController.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        // update the table view's data source
        updateInfo()
        refreshControl.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
            self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section)
        {
        case 0: return self.movies!.count
        case 1: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.backgroundColor = UIColor(red: 76/255.0, green: 76/255.0, blue: 76/255.0, alpha: 1.0)
        if movies!.count != 0 {
            let title = self.movies![indexPath.row]["title"] as! String
            cell.textLabel?.backgroundColor = UIColor.clear
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            cell.textLabel?.textColor = UIColor.white
            cell.textLabel?.text = title
        }
        
        return cell
    }
    
    // Get selected movie ID
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if movies!.count != 0 {
            let id = self.movies![indexPath.row]["id"] as! Int
        
            let movieID = String(id) as String
        
            // get movie details for selected movie
            downloadMovieData(movieID)
        }
    }
    
    // Download selected movie from the source and check network connection
    // solution from: http://docs.themoviedb.apiary.io/#reference/movies
    func downloadMovieData(_ id: String) {
        let url = URL(string: "http://api.themoviedb.org/3/movie/" + id + "?api_key=dfa910cc8fcf72c0ac1c5e26cf6f6df4")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data {
                self.parseMovieJSON(data)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "B_ViewMovieSegue", sender: nil)
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
        // Download movie
    }
    
    // Parse the received json result
    // solution from: https://github.com/SwiftyJSON/SwiftyJSON
    // and https://www.hackingwithswift.com/example-code/libraries/how-to-parse-json-using-swiftyjson
    func parseMovieJSON(_ movieJSON:Data){
        do{
            let result = try JSONSerialization.jsonObject(with: movieJSON,
                                                                    options: JSONSerialization.ReadingOptions.mutableContainers)
            let json = JSON(result)
            
            if let
                id = json["id"].int,
                let title = json["title"].string,
                let overview = json["overview"].string,
                let popularity = json["popularity"].double,
                let rate = json["vote_average"].double,
                let date = json["release_date"].string,
                let count = json["vote_count"].int{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                let release_date = dateFormatter.date(from: date)!
                if let
                    poster = json["poster_path"].string,
                    let backdrop = json["backdrop_path"].string {
                    // Store the info in Movie ojbect
                    let m: Movie = Movie(id: id, title: title, poster: poster, overview: overview, popularity: popularity, rate: rate, date: release_date, count: count, backdrop: backdrop)
                    currentMovie = m
                } else {
                    // Some movies may not provide poster and images
                    let m: Movie = Movie(id: id, title: title, poster: "No Poster", overview: overview, popularity: popularity, rate: rate, date: release_date, count: count, backdrop: "No Image")
                    currentMovie = m
                }
            }
        }catch {
            print("JSON Serialization error")
        }
    }
    
    // pass movie object to movie detail screen
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "B_ViewMovieSegue"
        {
            let controller: MovieViewController = segue.destination as! MovieViewController
            
            controller.currentMovie = currentMovie
            // Display movie details screen
        }
    }
}
