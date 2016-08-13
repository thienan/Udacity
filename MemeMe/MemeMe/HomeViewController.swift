//
//  HomeViewController.swift
//  MemeMe
//
//  Created by Ryan Harri on 2016-08-10.
//  Copyright © 2016 Ryan Harri. All rights reserved.
//

import UIKit
import Photos

class HomeViewController: UIViewController, Alertable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var photoAlbumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var changeFontButton: UIBarButtonItem!
    @IBOutlet weak var getStartedLabel: UILabel!
    
    private var activeField: UITextField!
    private var haveAccessToPhotoLibrary: Bool = false
    private var memeText: MemeText?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        memeText = MemeText()
        configureTextFields()
        configureUI(whenStateIs: MemeMeUIState.Start)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func configureTextFields() {
        if let memeText = memeText, memeTextAttributes = memeText.textAttributes {
            topTextField.defaultTextAttributes = memeTextAttributes
            topTextField.textAlignment = memeText.textAlignment
            topTextField.text = NSLocalizedString("TOP", comment: "TOP")
            topTextField.autocapitalizationType = memeText.autocapitalizationType
            topTextField.delegate = self
            
            bottomTextField.defaultTextAttributes = memeTextAttributes
            bottomTextField.textAlignment = memeText.textAlignment
            bottomTextField.text = NSLocalizedString("BOTTOM", comment: "BOTTOM")
            bottomTextField.autocapitalizationType = memeText.autocapitalizationType
            bottomTextField.delegate = self
        }
    }
    
    func configureUI(whenStateIs state: MemeMeUIState) {
        switch state {
        case .Start:
            topTextField.hidden = true
            bottomTextField.hidden = true
            shareButton.hidden = true
            trashButton.hidden = true
            changeFontButton.enabled = false
        case .ImageSelected:
            topTextField.hidden = false
            bottomTextField.hidden = false
            shareButton.hidden = false
            trashButton.hidden = false
            getStartedLabel.hidden = true
            changeFontButton.enabled = true
        case .Reset:
            topTextField.text = NSLocalizedString("TOP", comment: "TOP")
            bottomTextField.text = NSLocalizedString("BOTTOM", comment: "BOTTOM")
            imagePickerView.image = nil
            topTextField.hidden = true
            bottomTextField.hidden = true
            shareButton.hidden = true
            trashButton.hidden = true
            getStartedLabel.hidden = false
            changeFontButton.enabled = false
        case .GenerateMemeBegin:
            shareButton.hidden = true
            trashButton.hidden = true
            toolbar.hidden = true
        case .GenerateMemeEnd:
            shareButton.hidden = false
            trashButton.hidden = false
            toolbar.hidden = false
        }
    }
    
    @IBAction func shareButtonTapped(sender: AnyObject) {
        let memedImage = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            activityType, completed, returnedItems, activityError in
            self.save(memedImage)
        }
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        configureUI(whenStateIs: MemeMeUIState.GenerateMemeBegin)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        configureUI(whenStateIs: MemeMeUIState.GenerateMemeEnd)
        
        return memedImage
    }
    
    private func save(memedImage: UIImage) {
        if let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, image: imagePickerView.image!, memedImage: memedImage) {
            
            /* canhazbits (2014) iOS - Calling App Delegate method from ViewController
             Available at: http://stackoverflow.com/a/26417656 (Accessed: 10 Aug 2016) */
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                appDelegate.memes.append(meme)
            }
        }
    }
    
    @IBAction func trashButtonTapped(sender: AnyObject) {
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Default, handler: nil)
        
        let okAction = UIAlertAction(title: NSLocalizedString("I'm Sure", comment: "I'm sure"), style: .Cancel, handler: {
            (alert) -> Void in
            self.resetMeme()
        })
        
        displayAlert(NSLocalizedString("Are you sure?", comment: "Are you sure?"), message: NSLocalizedString("Your current meme will be discarded. This action cannot be undone", comment: "Cancel Meme Message"), cancelAction: cancelAction, okAction: okAction)
    }
    
    private func resetMeme () {
        configureUI(whenStateIs: MemeMeUIState.Reset)
    }
    
    @IBAction func changeFont(sender: AnyObject) {
        if let memeText = memeText {
            let font = memeText.nextFont
            topTextField.font = font
            bottomTextField.font = font
        }
    }
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBAction func pickAnImage(sender: AnyObject) {
        let photoLibraryAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoLibraryAuthorizationStatus {
        case .Authorized:
            if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = .PhotoLibrary
                presentViewController(imagePickerController, animated: true, completion: nil)
            }
        case .Denied:
            alertForPhotoLibraryAccess()
        case .NotDetermined:
            
            /* Just Shadow (2016) Determine if the access to photo library is set or not - iOS 8
             Available at: http://stackoverflow.com/a/38395022 (Accessed: 12 Aug 2016) */
            PHPhotoLibrary.requestAuthorization {
                status in
                if status == PHAuthorizationStatus.Denied {
                    self.alertForPhotoLibraryAccess()
                }
            }
        default:
            break
        }
    }
    
    /* DogCoffee (2016) Presenting camera permission dialog in iOS 8
     Available at: http://stackoverflow.com/a/31086823 (Accessed: 10 Aug 2016) */
    func alertForPhotoLibraryAccess() {
        let alert = UIAlertController(
            title: NSLocalizedString("Photo Library Access", comment: "Photo Library Access"),
            message: NSLocalizedString("MemeMe allows you to create memes with photos from your library. To allow this, go to your settings.", comment: "Photo Library Access Message"),
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: .Cancel, handler: { (alert) -> Void in
            
            /* 19Craig (2015) Error message '_BSMachError: (os/kern) invalid capability (20)'
             Available at: http://stackoverflow.com/a/33639650 (Accessed: 10 Aug 2016) */
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let avAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch avAuthorizationStatus {
        case .Authorized:
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .Camera
            presentViewController(imagePickerController, animated: true, completion: nil)
        case .Denied:
            alertForCameraAccess()
        case .NotDetermined:
            alertForCameraAccess()
        default:
            break
        }
    }
    
    /* DogCoffee (2016) Presenting camera permission dialog in iOS 8
     Available at: http://stackoverflow.com/a/31086823 (Accessed: 10 Aug 2016) */
    func alertForCameraAccess() {
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel"), style: .Default, handler: nil)
        
        let okAction = UIAlertAction(title: NSLocalizedString("Settings", comment: "Settings"), style: .Cancel, handler: {
            (alert) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
            }
        })
        
        displayAlert(NSLocalizedString("Camera Access", comment: "Camera Access"), message: NSLocalizedString("MemeMe allows you to create memes with photos taken from your camera. To allow this, go to your settings.", comment: "Camera Access Message"), cancelAction: cancelAction, okAction: okAction)
        
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = selectedImage
            imagePickerView.contentMode = .ScaleAspectFill
            imagePickerView.setNeedsDisplay()
            
            configureUI(whenStateIs: MemeMeUIState.ImageSelected)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension HomeViewController: UITextFieldDelegate {
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillBeHidden), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    /* DK_ (2015) How to make a UITextField move up when keyboard is present?
     Available at: http://stackoverflow.com/a/4837510 (Accessed: 8 Aug 2016) */
    func keyboardWillShow(notification: NSNotification) {
        if let info = notification.userInfo, let keyboardSize = info[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
            let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0)
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
            
            var aRect = self.view.frame
            aRect.size.height -= keyboardSize.height
            
            if !CGRectContainsPoint(aRect, activeField.frame.origin) {
                scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }

    func keyboardWillBeHidden(notification: NSNotification) {
        let contentInsets = UIEdgeInsetsZero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeField = nil
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.isFirstResponder() {
            return textField.resignFirstResponder()
        } else {
            return false
        }
    }
}