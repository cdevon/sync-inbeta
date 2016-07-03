//
//  EditViewController.swift
//  BrightonHartwell
//
//  Created by Christian Gibson on 6/28/16.
//  Copyright © 2016 Brighton Hartwell. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MessageUI
import Contacts
import MultipeerConnectivity
import ContactsUI

var name: String!
var company: String!
var job: String!
var phone: String!
var email: String!
var linked: String!
var busiImage: NSData!
var signedIn = "false"
class EditViewController: BluetoothController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var delegate: AddContactViewControllerDelegate!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var contactInfoView: UIView!
    @IBOutlet weak var jobInfoView: UIView!
    @IBOutlet weak var getStartedLabel: UILabel!
    //sign up information
    @IBOutlet weak var fullNameTF: UITextField!
    @IBOutlet weak var companyNameTF: UITextField!
    @IBOutlet weak var jobNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var linkedInTF: UITextField!
    var imageData: NSData!
    var imagePicker = UIImagePickerController()
    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var imagePickButton: UIButton!
    var imageDismissed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set signup delegates
        self.fullNameTF.delegate = self
        self.companyNameTF.delegate = self
        self.jobNameTF.delegate = self
        self.emailTF.delegate = self
        self.phoneTF.delegate = self
        self.linkedInTF.delegate = self
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        if self.imageDismissed == false {
            print(signedIn)
            if signedIn == "false" {
                //fetching user contact on load
                //1
                let appDelegate =
                    UIApplication.sharedApplication().delegate as! AppDelegate
                
                let managedContext = appDelegate.managedObjectContext
                
                //2
                let fetchRequest = NSFetchRequest(entityName: "Contact")
                
                //3
                
                if contact == nil {
                    do {
                        let results =
                            try managedContext.executeFetchRequest(fetchRequest)
                        if results.count != 0 { //if contact found
                            contact = (results as! [NSManagedObject])[0]
                            
                            name = contact.valueForKey("name") as? String
                            job = contact.valueForKey("profession") as? String
                            company = contact.valueForKey("company") as? String
                            phone = contact.valueForKey("phone") as? String
                            email = contact.valueForKey("email") as? String
                            linked = contact.valueForKey("linkedIn") as? String
                            busiImage = contact.valueForKey("businessCard") as! NSData
                            //self.performSegueWithIdentifier("signinSegue", sender: self)
                            print("found contact")
                            //self.createContact()
                        } else {
                            print("no contacts")
                        }
                    } catch let error as NSError {
                        print("Could not fetch \(error), \(error.userInfo)")
                    }
                }
                
            } else {
                self.getStartedLabel.text = "Edit Information"
                self.fullNameTF.text = name
                self.companyNameTF.text = company
                self.jobNameTF.text = job
                self.emailTF.text = email
                self.phoneTF.text = phone
                self.linkedInTF.text = linked
                self.imagePreview.image = UIImage(data: busiImage)
                self.imageData = busiImage
            }
            
            if contact != nil && signedIn == "false" {
                signedIn = "true"
                //in order to fetch contacts from iPhone
                appDelegate.requestForAccess { (accessGranted) -> Void in
                    if accessGranted {
                        let contactsStore = appDelegate.contactStore
                        let predicate = CNContact.predicateForContactsMatchingName(contact.valueForKey("name") as! String)
                        print(contact.valueForKey("name") as! String)
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
                            print(message)
                            theContact = contacts[0]
                            print(theContact.givenName)
                            peerID = MCPeerID(displayName: theContact.givenName)
                            mainSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .Required)
                            mainSession.delegate = self
                            self.performSegueWithIdentifier("signinSegue", sender: self)
                        }
                        
                        if message != "" {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                //appDelegate.showMessage(message)
                            })
                        } else {
                            
                        }
                    }
                    
                }
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        self.container.bringSubviewToFront(self.jobInfoView)
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.container.sendSubviewToBack(self.jobInfoView)
    }
    
    @IBAction func finishButtonTapped(sender: AnyObject) {
        self.saveContactInfo(self)
        if theContact == nil {
            self.createContact()
            self.performSegueWithIdentifier("signinSegue", sender: self)
        }
    }
    
    func createContact() {
        let newContact = CNMutableContact()
        
        let name = contact.valueForKey("name") as! String
        let profession = contact.valueForKey("profession") as! String
        let company = contact.valueForKey("company") as! String
        let phone = contact.valueForKey("phone") as! String
        let phoneNum = CNPhoneNumber(stringValue: phone)
        let email = contact.valueForKey("email") as! String
        let linkedIn = contact.valueForKey("linkedIn") as! String
        let businessCard = contact.valueForKey("businessCard") as! NSData
        
        let workEmail = CNLabeledValue(label: CNLabelWork, value: email)
        
        let phoneNumber = CNLabeledValue(label: CNLabelPhoneNumberMobile, value: phoneNum)
        let linkedInObj = CNLabeledValue(label: CNLabelURLAddressHomePage, value: linkedIn)
        
        newContact.givenName = name
        newContact.imageData = businessCard
        newContact.jobTitle = profession
        newContact.organizationName = company
        newContact.emailAddresses = [workEmail]
        newContact.phoneNumbers = [phoneNumber]
        newContact.urlAddresses = [linkedInObj]
        newContact.note = "Saved with SyncedIn"
        
        
        do {
            let saveRequest = CNSaveRequest()
            saveRequest.addContact(newContact, toContainerWithIdentifier: nil)
            
            try appDelegate.contactStore.executeSaveRequest(saveRequest)
            
            contactObj = newContact
            print("gotcha")
            print("swag")
            //navigationController?.popViewControllerAnimated(true)
        }
        catch {
            print("error")
        }
    }
    
    //gather signup info -> save to CoreData
    @IBAction func saveContactInfo(sender: AnyObject) {
        if self.fullNameTF.text?.characters.count != 0 {
            informationArray[0] = self.fullNameTF.text!
        } else {
            return
        }
        
        if self.jobNameTF.text?.characters.count != 0 {
            informationArray[1] = self.jobNameTF.text!
        } else {
            informationArray[1] = ""
        }
        
        if self.companyNameTF.text?.characters.count != 0 {
            informationArray[2] = self.companyNameTF.text!
        } else {
            informationArray[2] = ""
        }
        
        if self.phoneTF.text?.characters.count != 0 {
            informationArray[3] = self.phoneTF.text!
        } else {
            informationArray[3] = ""
        }
        
        if self.emailTF.text?.characters.count != 0 {
            informationArray[4] = self.emailTF.text!
        } else {
            return
        }
        
        if self.linkedInTF.text?.characters.count != 0 {
            informationArray[5] = self.linkedInTF.text!
        } else {
            informationArray[5] = ""
        }
        
        var imageData: NSData!
        
        if self.imageData.length != 0 {
            imageData = self.imageData
        } else {
            imageData = UIImagePNGRepresentation(UIImage(named: "busiCard.jpg")!)
        }
        
        print("saving contact")
        self.saveContact(informationArray, imageData: imageData)
    }
    
    //save to CoreData
    func saveContact(informationArray: [String], imageData: NSData!) {
        //1
        let appDelegate =
            UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        
        let uname = informationArray[0]
        let profession = informationArray[1]
        let ucompany = informationArray[2]
        let uphone = informationArray[3]
        let uemail = informationArray[4]
        let linkedIn = informationArray[5]
        let businessCard = imageData
        
        //3
        if signedIn == "false" {
            //2
            //let entity =  NSEntityDescription.entityForName("Contact", inManagedObjectContext:managedContext)
            
            let contactObj = NSEntityDescription.insertNewObjectForEntityForName("Contact", inManagedObjectContext: managedContext)
            //NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
            
            contactObj.setValue(uname, forKey: "name")
            contactObj.setValue(profession, forKey: "profession")
            contactObj.setValue(ucompany, forKey: "company")
            contactObj.setValue(uphone, forKey: "phone")
            contactObj.setValue(uemail, forKey: "email")
            contactObj.setValue(linkedIn, forKey: "linkedIn")
            contactObj.setValue(businessCard, forKey: "businessCard")
            
            //4
            do {
                print("saving")
                try managedContext.save()
                print("saved")
                //5
                contact = contactObj
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        } else {
            contact.setValue(uname, forKey: "name")
            contact.setValue(profession, forKey: "profession")
            contact.setValue(ucompany, forKey: "company")
            contact.setValue(uphone, forKey: "phone")
            contact.setValue(uemail, forKey: "email")
            contact.setValue(linkedIn, forKey: "linkedIn")
            contact.setValue(businessCard, forKey: "businessCard")
            
            //4
            do {
                print("saving")
                try managedContext.save()
                print("saved")
                
                name = self.fullNameTF.text
                job = self.jobNameTF.text
                company = self.companyNameTF.text
                phone = self.phoneTF.text
                email = self.emailTF.text
                linked = self.linkedInTF.text
                busiImage = imageData
                signedIn = "true"
                let ac = UIAlertController(title: "Saved", message: "Your information has been saved!", preferredStyle: .Alert)
                
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) in
                    
                }))
                
                self.presentViewController(ac, animated: true, completion: nil)
                //self.performSegueWithIdentifier("signinSegue", sender: self)
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func AddImageButton(sender : AnyObject) {
        self.imagePicker.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.imagePicker.allowsEditing = false
        self.presentViewController(self.imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //self.imagePreview.contentMode = .ScaleAspectFit
            self.imagePreview.image = pickedImage
            self.imageData = UIImagePNGRepresentation(pickedImage)
            busiImage = UIImagePNGRepresentation(pickedImage)
            
        }
        self.imageDismissed = true
        self.dismissViewControllerAnimated(true, completion: nil)
        self.nextButtonTapped(self)
        self.imagePickButton.setTitle("", forState: .Normal)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        self.nextButtonTapped(self)
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
