//
//  FeedViewController.swift
//  HackerNewsReader
//
//  Created by Jesús on 08/06/14.
//  Copyright (c) 2014 Jesús. All rights reserved.
//

import UIKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate {

    @IBOutlet var tableView : UITableView
    @IBOutlet var loadingIndicator : UIActivityIndicatorView
    
    var newsItems : String[]
    var links : String[]
    
    var tmpNewsItem : String
    
    var isTitleTag : Bool
    var isLinkTag : Bool
    
    init(coder aDecoder: NSCoder!)
    {
        newsItems = []
        links = []
        tmpNewsItem = ""
        
        isTitleTag = false
        isLinkTag = false
        
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad()
    {
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier : "cellIdentifier")
        _loadRSS("https://news.ycombinator.com/rss")
    }
    
    
    //MARK: Private
    
    func _loadRSS(rssUrl : String)
    {
        loadingIndicator.startAnimating()
        
        let url = NSURL(string:rssUrl)
        let request = NSURLRequest(URL:url)
        
        var _self = self
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithRequest(request,
            completionHandler : { (data : NSData!, response : NSURLResponse!, error : NSError!) in
                var parser = NSXMLParser(data:data)
                parser.delegate = _self
                parser.parse()
                
                dispatch_async(dispatch_get_main_queue()) {
                    _self.loadingIndicator.stopAnimating()
                }
            }
        )
        task.resume()
    }
    
    
    //MARK: UITableViewDelegate methods
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        var link = links[indexPath.row]
        var url = NSURL(string : link)
        UIApplication.sharedApplication().openURL(url)
    }
    
    
    //MARK: UITableViewDataSource methods
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int
    {
        return newsItems.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!
    {
        var cell : UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cellIdentifier", forIndexPath: indexPath) as UITableViewCell;
        var newsTitle = newsItems[indexPath.row]
        cell.textLabel.text = newsTitle
        return cell
    }
    
    
    //MARK: NSXMLParserDelegate
    
    func parserDidStartDocument(parser: NSXMLParser!)
    {
        newsItems = []
        links = []
    }
    
    
    func parserDidEndDocument(parser: NSXMLParser!)
    {
        var _self = self
        dispatch_async(dispatch_get_main_queue()) {
            _self.tableView.reloadData()
        }
    }
    
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: NSDictionary!)
    {
        tmpNewsItem = ""
        isTitleTag = (elementName == "title")
        isLinkTag = (elementName == "link")
    }
    
    
    func parser(parser: NSXMLParser!, didEndElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!)
    {
        if isTitleTag {
            newsItems.append(tmpNewsItem)
        } else if isLinkTag {
            links.append(tmpNewsItem)
        }
    }
    
    
    func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {
        if isTitleTag || isLinkTag {
            tmpNewsItem += string
        }
    }
}
