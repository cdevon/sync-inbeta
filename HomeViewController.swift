//
//  ViewController.swift
//  BrightonHartwell
//
//  Created by Christian Gibson on 6/18/16.
//  Copyright © 2016 Brighton Hartwell. All rights reserved.
//


import UIKit
import Foundation
import CoreData
import MessageUI
import Contacts
import MultipeerConnectivity
import ContactsUI

var contact: NSManagedObject! //user's CoreData contact

var contactObj: CNMutableContact! //made to send contact to another user via bluetooth
//currently running into some trouble, check back later

var theContact: CNContact!

var recievedContact: CNMutableContact! //contact made after retrieved from another user

var informationArray = [String](count: 6, repeatedValue: "") //String array of user information
//sent easier over bluetooth
var imageData: NSData! //user's busi card data

var appDelegate: AppDelegate!

protocol AddContactViewControllerDelegate {
    func didFetchContacts(contacts: [CNContact])
}

class ViewController: BluetoothController, UITextFieldDelegate,  CNContactPickerDelegate {
    
    var effectAdded = "false"
    var delegate: AddContactViewControllerDelegate!
    
    //information displayed on home page
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var jobNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var linkedInLabel: UILabel!
    @IBOutlet weak var busiCardImageView: UIImageView!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        appDelegate.requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                let contactsStore = appDelegate.contactStore
                let predicate = CNContact.predicateForContactsMatchingName(contact.valueForKey("name") as! String)
                let keysToFetch = [
                    CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),
                    CNContactEmailAddressesKey,
                    CNContactPhoneNumbersKey,
                    CNContactImageDataKey,CNContactGivenNameKey, CNContactNoteKey, CNContactJobTitleKey, CNContactFamilyNameKey, CNContactUrlAddressesKey, CNContactOrganizationNameKey]
                //let keysToFetch = [CNContactGivenNameKey]
                // Get all the containers
                //var allContainers: [CNContainer] = []
                var results: [CNContact] = []
                do {
                    results = try contactsStore.unifiedContactsMatchingPredicate(
                        predicate, keysToFetch: keysToFetch)
                } catch {
                    print("Error fetching containers")
                }
                
                let contacts = results
                var message = ""
                if contacts.count == 0 {
                    message = "No contacts were found matching the given name."
                    print(message)
                } else {
                    message = "Got your contact!"
                    theContact = contacts[0]
                    print(theContact.givenName)
                    peerID = MCPeerID(displayName: theContact.givenName)
                    mainSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .Required)
                    mainSession.delegate = self
                    //print("saved")
                    
                    name = contact.valueForKey("name") as? String
                    job = contact.valueForKey("profession") as? String
                    company = contact.valueForKey("company") as? String
                    phone = contact.valueForKey("phone") as? String
                    email = contact.valueForKey("email") as? String
                    linked = contact.valueForKey("linkedIn") as? String
                    busiImage = contact.valueForKey("businessCard") as! NSData
                    signedIn = "true"
                    //self.performSegueWithIdentifier("signinSegue", sender: self)
                }
                
                if message != "" {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //appDelegate.showMessage(message)
                    })
                } else {
                    
                }
                
                
            }
            
        }

        
        self.fullNameLabel.text = name
        self.jobNameLabel.text = job
        self.companyNameLabel.text = company
        self.phoneLabel.text = phone
        self.emailLabel.text = email
        self.linkedInLabel.text = linked
        
        if self.effectAdded == "false" {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.busiCardImageView.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        self.busiCardImageView.addSubview(blurEffectView)
        self.busiCardImageView.image = UIImage(data: busiImage)
            self.effectAdded = "true"
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //Contacts button tapped brings up regular contact screen
    @IBAction func showContacts(sender: AnyObject) {
        let contactPickerViewController = CNContactPickerViewController()
        
        contactPickerViewController.delegate = self
        
        presentViewController(contactPickerViewController, animated: true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        //delegate.didFetchContacts([contact])
        navigationController?.popViewControllerAnimated(true)
    }
    
  }




