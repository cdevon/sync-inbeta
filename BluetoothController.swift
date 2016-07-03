//
//  BluetoothController.swift
//  BrightonHartwell
//
//  Created by Christian Gibson on 6/27/16.
//  Copyright © 2016 Brighton Hartwell. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Contacts
import ContactsUI

var peerID: MCPeerID!
var mainSession: MCSession!
var mcAdvertiserAssistant: MCAdvertiserAssistant!

class BluetoothController: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    //let contactService = ContactServiceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func startHosting() {
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-kb", discoveryInfo: nil, session: mainSession)
        mcAdvertiserAssistant.start()
        print("hosting")
        
    }
    
    func joinSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-kb", session: mainSession)
        mcBrowser.delegate = self
        self.presentViewController(mcBrowser, animated: true, completion: nil)
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state {
        case MCSessionState.Connected:
            
            let q = UIAlertController(title: "Connected", message: "Would you like to send or recieve?", preferredStyle: .Alert)
            let send = UIAlertAction(title: "Send", style: .Default, handler: { (action) in
                let ac = UIAlertController(title: "Connected", message: "Connected with " + peerID.displayName, preferredStyle: .Alert)
                let sendCard = UIAlertAction(title: "Send Card Image", style: .Default, handler: { (action) in
                    self.sendImage(theContact.imageData!)
                })
                let sendContact = UIAlertAction(title: "Send SyncCard", style: .Default, handler: { (action) in
                    self.sendContactsToPeer(peerID, contacts: [theContact])
                })
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
                    self.dismissViewControllerAnimated(true, completion: nil)
                })
                ac.addAction(sendContact)
                ac.addAction(sendCard)
                ac.addAction(cancel)
                
                self.presentViewController(ac, animated: true, completion: nil)
            })
            let receive = UIAlertAction(title: "Receive", style: .Default, handler: { (action) in
                print("receiving")
            })
            q.addAction(send)
            q.addAction(receive)
            self.presentViewController(q, animated: true, completion: nil)
            
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.Connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.NotConnected:
            let ac = UIAlertController(title: "Not Connected", message: "Failed to connect with " + peerID.displayName, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(ac, animated: true, completion: nil)
            
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func sendContactsToPeer(peerId: MCPeerID, contacts: [CNContact]) {
        if mainSession.connectedPeers.count > 0 {
            if let contactsData: NSData = NSKeyedArchiver.archivedDataWithRootObject(contacts) {
                do {
                    try mainSession.sendData(NSKeyedArchiver.archivedDataWithRootObject(contactsData), toPeers: mainSession.connectedPeers, withMode: MCSessionSendDataMode.Reliable)
                    
                    let ac = UIAlertController(title: "Sent", message: "Sent contact to" + peerID.displayName, preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
                } catch {
                    print("Unable to send contacts data to \(peerId.displayName)")
                }
            }
        }
        
    }
    
    func sendImage(imageData: NSData) {
        let ac = UIAlertController(title: "Important Message", message: "Make sure the receipient has their AirPlay on", preferredStyle: .Alert)
        
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            
            let controller = UIActivityViewController(activityItems: [theContact.imageData!], applicationActivities: nil)
            controller.excludedActivityTypes = [UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard,  UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypeMail]
            self.presentViewController(controller, animated: true, completion: nil)
            
        }))
        
        self.presentViewController(ac, animated: true, completion: nil)
        
    }
    
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        print("Received data: \(data) From Peer: \(peerID)")
        
        
        if let contactsData: NSData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? NSData {
            if let contacts: [CNContact] = NSKeyedUnarchiver.unarchiveObjectWithData(contactsData) as? [CNContact] {
                dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                    let contact = contacts[0]
                    
                    let newContact = CNMutableContact()
                    newContact.givenName = contact.givenName
                    newContact.imageData = contact.imageData
                    newContact.jobTitle = contact.jobTitle
                    newContact.organizationName = contact.organizationName
                    newContact.emailAddresses = contact.emailAddresses
                    newContact.phoneNumbers = contact.phoneNumbers
                    newContact.urlAddresses = contact.urlAddresses
                    newContact.note = "Saved with SyncedIn"
                    
                    let saveRequest = CNSaveRequest()
                    saveRequest.addContact(newContact, toContainerWithIdentifier: nil)
                    do {
                        try appDelegate.contactStore.executeSaveRequest(saveRequest)
                        let ac = UIAlertController(title: "Saved", message: "Saved contact from " + peerID.displayName, preferredStyle: .Alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                        self.presentViewController(ac, animated: true, completion: nil)
                        
                    } catch {
                        print("error")
                    }
                }
            }
        }
    } 
}
