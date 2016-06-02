//
//  SubscriptionsListTableViewController.swift
//  app-ios
//
//  Created by Sinan Ulkuatam on 6/1/16.
//  Copyright © 2016 Sinan Ulkuatam. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON
import CWStatusBarNotification
import MCSwipeTableViewCell

class SubscriptionsListTableViewController: UITableViewController, MCSwipeTableViewCellDelegate {
    
    var itemsArray:Array<Subscription>?
    
    var viewRefreshControl = UIRefreshControl()
    
    var dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Subscriptions"
        self.navigationController?.navigationBar.tintColor = UIColor.lightBlue()
        
        showGlobalNotification("Loading subscriptions", duration: 3.0, inStyle: CWNotificationAnimationStyle.Top, outStyle: CWNotificationAnimationStyle.Top, notificationStyle: CWNotificationStyle.StatusBarNotification, color: UIColor.lightBlue())
        
        self.dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        self.dateFormatter.timeStyle = NSDateFormatterStyle.LongStyle
        
        self.viewRefreshControl.backgroundColor = UIColor.clearColor()
        
        self.viewRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.viewRefreshControl.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView?.addSubview(viewRefreshControl)
        
        self.loadSubscriptionList()
    }
    
    func loadSubscriptionList() {
        Subscription.getSubscriptionList({ (subscriptions, error) in
            if error != nil
            {
                let alert = UIAlertController(title: "Error", message: "Could not load subscriptions \(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            self.itemsArray = subscriptions
            
            // update "last updated" title for refresh control
            let now = NSDate()
            let updateString = "Last Updated at " + self.dateFormatter.stringFromDate(now)
            self.viewRefreshControl.attributedTitle = NSAttributedString(string: updateString)
            if self.viewRefreshControl.refreshing
            {
                self.viewRefreshControl.endRefreshing()
            }
            self.tableView?.reloadData()
        })
    }
    
    func timeStringFromUnixTime(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = NSDateFormatter()
        
        // Returns date formatted as 12 hour time.
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.stringFromDate(date)
    }
    
    func dayStringFromTime(unixTime: Double) -> String {
        let dateFormatter = NSDateFormatter()
        let date = NSDate(timeIntervalSince1970: unixTime)
        dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.stringFromDate(date)
    }
    
    func refresh(sender:AnyObject)
    {
        self.loadSubscriptionList()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsArray?.count ?? 0
    }
    
    // MARK DELEGATE MCTABLEVIEWCELL
    
    func viewWithImageName(name: String) -> UIView {
        let image: UIImage = UIImage(named: name)!;
        let imageView: UIImageView = UIImageView(image: image);
        imageView.contentMode = UIViewContentMode.Center;
        return imageView;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier: String = "cell";
        var cell: MCSwipeTableViewCell! = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! MCSwipeTableViewCell!;
        if cell == nil {
            cell = MCSwipeTableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: CellIdentifier);
            cell!.selectionStyle = UITableViewCellSelectionStyle.Gray;
            cell!.contentView.backgroundColor = UIColor.whiteColor();
            cell.textLabel?.tintColor = UIColor.lightBlue()
            cell.detailTextLabel?.tintColor = UIColor.lightBlue().colorWithAlphaComponent(0.5)
            cell.tag = indexPath.row
            
            let item = self.itemsArray?[indexPath.row]
            if let name = item?.plan_name, id = item?.id, status = item?.status {
                cell.textLabel?.text = name + " | Status: " + status
                cell.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 15)!
            }
            if let amount = item?.plan_amount, interval = item?.plan_interval {
                // cell!.detailTextLabel?.text = "Current $" + current + " | " + "Available $" + available
                cell.detailTextLabel?.attributedText = formatCurrency(amount, fontName: "HelveticaNeue-Light", superSize: 11, fontSize: 14, offsetSymbol: 3, offsetCents: 3) +  NSAttributedString(string: " / ") +  NSAttributedString(string:  interval)
            }
        }
        
        let closeView: UIView = self.viewWithImageName("ic_close_light");
        
        cell.setSwipeGestureWithView(closeView, color:  UIColor.brandRed(), mode: .Exit, state: .State3) {
            (cell : MCSwipeTableViewCell!, state : MCSwipeTableViewCellState!, mode : MCSwipeTableViewCellMode!) in
            let item = self.itemsArray?[cell.tag]
            if let id = item?.id {
                print("Did swipe" + id);
                // send request to delete the bank account, on completion reload table data!
                Subscription.deleteSubscription(id, completionHandler: { (bool, err) in
                    print("deleted subscription ", bool)
                    self.loadSubscriptionList()
                })
            }
        };
        
        return cell;
    }
    
}
