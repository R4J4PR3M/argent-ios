//
//  SearchMessageViewController.swift
//  app-ios
//
//  Created by Sinan Ulkuatam on 5/27/16.
//  Copyright © 2016 Sinan Ulkuatam. All rights reserved.
//

import Foundation
import JGProgressHUD
import Alamofire
import TransitionTreasury
import TransitionAnimation

class SearchMessageViewController: UIViewController, UINavigationBarDelegate, NavgationTransitionable {
    
    var tr_pushTransition: TRNavgationTransitionDelegate?
    
    weak var modalDelegate: ModalViewControllerDelegate?
    
    @IBOutlet weak var message: UITextView!
    
    private let HUD: JGProgressHUD = JGProgressHUD.init(style: JGProgressHUDStyle.Light)
    
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesBarsOnSwipe = false
        message.becomeFirstResponder()
        setupNav()
    }
    
    override func viewWillAppear(animated: Bool) {
        addSendOnKeyboard()
    }
    
    // Add send toolbar
    func addSendOnKeyboard()
    {
        let screen = UIScreen.mainScreen().bounds
        let screenWidth = screen.size.width
        let sendToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, screenWidth, 50))
        // sendToolbar.barStyle = UIBarStyle.Default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Done, target: self, action: #selector(self.sendMessageAction))
        UIToolbar.appearance().barTintColor = UIColor.mediumBlue()
        UIToolbar.appearance().backgroundColor = UIColor.mediumBlue()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(15), NSForegroundColorAttributeName:UIColor.whiteColor()], forState: UIControlState.Normal)
        
        var items: [UIBarButtonItem]? = [UIBarButtonItem]()
        items?.append(flexSpace)
        items?.append(done)
        items?.append(flexSpace)
        
        sendToolbar.items = items
        sendToolbar.sizeToFit()
        message.inputAccessoryView=sendToolbar
    }
    
    @IBAction func sendMessageAction() {
        if message.text == "" {
            HUD.showInView(self.view!)
            HUD.textLabel.text = "Message cannot be empty"
            HUD.indicatorView = JGProgressHUDErrorIndicatorView()
            HUD.dismissAfterDelay(2.5)
        } else {
            sendMessage()
        }
    }
    
    private func setupNav() {
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 60)) // Offset by 20 pixels vertically to take the status bar into account
        
        navigationBar.backgroundColor = UIColor.clearColor()
        navigationBar.tintColor = UIColor.mediumBlue()
        navigationBar.delegate = self
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = ""
        
        // Make the navigation bar a subview of the current view controller
        self.view.addSubview(navigationBar)
    }
    
    func returnToMenu(sender: AnyObject) {
        self.view.window!.rootViewController!.dismissViewControllerAnimated(true, completion: { _ in })
    }

    func sendMessage() {
        HUD.showInView(self.view!)
        User.getProfile { (user, err) in
            
            let parameters : [String : AnyObject] = [
                "message": self.message.text,
            ]
            
            let headers : [String : String] = [
                "Content-Type": "application/json"
            ]
            
            Alamofire.request(.POST, API_URL + "/v1/message/user/" + self.username!, parameters: parameters, encoding: .JSON, headers: headers)
                .responseJSON { (response) in
                    switch response.result {
                    case .Success:
                        if let value = response.result.value {
                            self.HUD.textLabel.text = "Message sent!"
                            self.HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
                            self.HUD.dismissAfterDelay(1, animated: true)
                            self.message.text = ""
                        }
                    case .Failure(let error):
                        print(error)
                    }
            }
        }
    }
}