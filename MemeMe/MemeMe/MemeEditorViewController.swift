//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Ransom Barber on 4/28/15.
//  Copyright (c) 2015 Hart Book. All rights reserved.
//

import UIKit
import Foundation


class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var shareMemeButton: UIBarButtonItem!

    @IBOutlet weak var imagePickerView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    var meme: Meme!
    
    // Define the text field attributes.
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.blackColor(),
        NSForegroundColorAttributeName: UIColor.whiteColor(),
        NSStrokeWidthAttributeName: -3.0,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 20)!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign textField delegates
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide share button until meme has an image.
        if let image = imagePickerView.image {
            shareMemeButton.enabled = true
        } else {
            shareMemeButton.enabled = false
        }
        
        // Hide camera button image unless the device has a camera
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // Subscribe to keyboard notifications to bring up keyboard when typing in textField begins.
        self.subscribeToKeyboardNotifications()
        
        // Replace the back button with the share button.
        self.navigationItem.leftBarButtonItem = self.shareMemeButton
        
        // Ensure only appropriate bars are visible.
        self.tabBarController!.tabBar.hidden = true
        self.navigationController!.toolbarHidden = false
        self.navigationController!.navigationBarHidden = false

        // Set appearance of text fields.
        textFieldWithSettings(self.topTextField)
        textFieldWithSettings(self.bottomTextField)
        
        self.topTextField.text = "TOP"
        self.bottomTextField.text = "BOTTOM"
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unsubscribe from keyboard notifications when segueing.
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // Set any text field with the chosen settings.
    func textFieldWithSettings(textField: UITextField) {
        textField.defaultTextAttributes = self.memeTextAttributes
        textField.backgroundColor = UIColor.clearColor()
        textField.borderStyle = .None
        textField.textAlignment = NSTextAlignment.Center
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Clear default text.
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Drop keyboard when Return is tapped.
        textField.resignFirstResponder()
        return true
    }

    @IBAction func shareImage(sender: UIBarButtonItem) {
        // Save the meme first so can access the image for sharing.
        self.saveMeme()
        
        // Unwrap the image optional.
        if let image = self.meme.memedImage {
            // Access the ActivityViewController to select method of sharing
            let shareController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            // Set the closure of the completion handler so segues to root view controller upon completion of sharing.
            shareController.completionWithItemsHandler = {(activity, success, items, error) in
                if success {
                    // Access the application-wide array of memes and add self.meme.
                    // (Placed here, prevents adding meme to array if activity is canceled.)
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.memes.append(self.meme)
                    
                    // Segue to root view controller upon completion.
                    self.goToHeadOfTheLine()
                }}
            
            // Slide up the activity view controller
            self.presentViewController(shareController, animated: true, completion: nil)
        }
    }
    
    func saveMeme() {
        // Ensure text fields are not empty.
        if self.topTextField.text.isEmpty {
            self.topTextField.text = ""
        }
        
        if self.bottomTextField.text.isEmpty {
            self.bottomTextField.text = ""
        }
        
        if let image = imagePickerView.image {
            // Create meme-model and assign it to self.meme.
            self.meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: image, memedImage: generateMemedImage())
        } else {
            // Return to root view controller if no image for meme. Redundant as no Share Icon if no image, but just in case.
            self.goToHeadOfTheLine()
        }
    }
    
    // Create and return an image that incorporates the overlaid text into the original image.
    func generateMemedImage() -> UIImage {
        // Ensure no bars are visible in the shot.
        self.navigationController!.toolbarHidden = true
        self.navigationController!.navigationBarHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Replace the bars for next views
        self.navigationController!.toolbarHidden = false
        self.navigationController!.navigationBarHidden = false
        
        return memedImage
    }
    
    func goToHeadOfTheLine() {
        // Instantiate a controller and pop to the root view controller.
        let controller = self.navigationController!.viewControllers[0] as! UIViewController
        self.navigationController!.popToViewController(controller, animated: true)
    }
    
    @IBAction func cancelMeme(sender: UIBarButtonItem) {
        // Pop to the root view controller without saving the meme.
        self.goToHeadOfTheLine()
    }
    
    // Access the album and select an image.
    @IBAction func pickAnImageFromAlbum(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Access the camera and take an image to use.
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    // Assign the selected image to self image picker view, then dismiss the image picker controller.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickerView.image = image
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Dismiss the image picker controller without making a selection.
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    // Return a float value of the height of the keyboard being used.
    func getKeyBoardHeight(notificaton: NSNotification) -> CGFloat {
        let userInfo = notificaton.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    // Slide the whole view up to show the text field when the bottom text field is selected.
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y = -getKeyBoardHeight(notification)
        }
    }
    
    // Slide the whole view down to original position when the bottom text field is selected, and then the return key is tapped.
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            self.view.frame.origin.y = 0
        }
    }
    
    // Subscribe to keyboard notifications to show and hide the keyboard appropriately.
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Unsubscribe from keyboard notifications when segueing to another view controller.
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
}

