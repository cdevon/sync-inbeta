//
//  SyncViewController.swift
//  BrightonHartwell
//
//  Created by Christian Gibson on 6/27/16.
//  Copyright © 2016 Brighton Hartwell. All rights reserved.
//

import UIKit

class SyncViewController: BluetoothController {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var nonButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.startButton.layer.cornerRadius = self.startButton.frame.size.width / 2.0
        self.joinButton.layer.cornerRadius = self.joinButton.frame.size.width / 2.0
        self.nonButton.layer.cornerRadius = self.nonButton.frame.size.width / 2.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startSync(sender: AnyObject?) {
        self.startHosting()
    }
    
    @IBAction func joinSync(sender: AnyObject?) {
        self.joinSession()
    }
    
    @IBAction func shareContact(sender: AnyObject) {
        let ac = UIAlertController(title: "Important Message", message: "Make sure the receipient has their AirPlay on", preferredStyle: .Alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            
            let controller = UIActivityViewController(activityItems: [theContact.imageData!], applicationActivities: nil)
            controller.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard,  UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypeMail]
            self.presentViewController(controller, animated: true, completion: nil)
            
        }))
        
        self.presentViewController(ac, animated: true, completion: nil)
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
