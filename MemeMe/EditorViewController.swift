//
//  EditorViewController
//  ImagePicker
//
//  Created by Riving Amin on 20/05/15.
//  Copyright (c) 2015 Riving Amin. All rights reserved.
//

import UIKit

class EditorViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UIGestureRecognizerDelegate {

    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    var cameraButton = UIBarButtonItem()
    var flexiblespace = UIBarButtonItem()
    var pickImageButton = UIBarButtonItem()
    var shareButton = UIBarButtonItem()
    var cancelButton = UIBarButtonItem()
    
    var memedImage = UIImage()
    var meme:Meme!
    
    
    let tapRec = UITapGestureRecognizer()
    let panRec = UIPanGestureRecognizer()
    var lastLocation:CGPoint = CGPointMake(0, 0){
        didSet{
            self.imagePickerView.center = lastLocation
        }
    }

    var keyboardHidden = true
    var toolbarHidden:Bool = false {
        didSet{
            hide(toolbarHidden,animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var fixedWidth = self.view.frame.size.width;
        var fixedHeight = self.view.frame.size.height;
        
        self.navigationController?.view.backgroundColor = UIColor.whiteColor()
        bottomTextField.sizeToFit()
        
        
        //tap gesture recognizer
        tapRec.addTarget(self, action: "tapped")
        tapRec.delegate = self
        view.addGestureRecognizer(tapRec)
        
        //pan gesture recognizer
        panRec.addTarget(self, action: "detectPan:")
        panRec.delegate = self
        panRec.cancelsTouchesInView = false;
        panRec.delaysTouchesEnded = false
        view.addGestureRecognizer(panRec)

        pickImageButton = UIBarButtonItem(title: "Album", style: .Done, target: self, action: "pickAnImageFromAlbum:")
        cameraButton = UIBarButtonItem(barButtonSystemItem: .Camera, target: self, action: "pickAnImageFromCamera:")
        shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "share")
        cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel")
        flexiblespace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
      
        
        //Text, font, style
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "Helvetica Neue", size: 40)!,
            NSStrokeWidthAttributeName : -4
        ]
        
        
        
        topTextField.backgroundColor = UIColor.clearColor()
        bottomTextField.backgroundColor = UIColor.clearColor()
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.textAlignment = .Center
        bottomTextField.textAlignment = .Center
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        if(!UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            cameraButton.enabled = false
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Image pos
        self.imagePickerView.transform = CGAffineTransformIdentity
        lastLocation = self.imagePickerView.center
        
        //Editing
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        self.meme = applicationDelegate.editorMeme
        
        //Current meme image draw
        self.navigationItem.leftBarButtonItem = shareButton
        topTextField.text = meme.topText
        bottomTextField.text = meme.bottomText
        imagePickerView.image = meme.image
        
        //Enable sharebutton
        if(imagePickerView.image?.size == UIImage().size){
            shareButton.enabled = false
        }else{
            shareButton.enabled = true
        }

        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.rightBarButtonItem = cancelButton
        self.toolbarItems = [flexiblespace,cameraButton,flexiblespace,pickImageButton,flexiblespace]
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
  
    
    @IBAction func pickAnImageFromCamera(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
   
    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            self.imagePickerView.image = image
            meme.image = image
            meme.topText = self.topTextField.text
            meme.bottomText = self.bottomTextField.text
        }

        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

    
    //Cancel function
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    
    //Cancel button action
    func cancel(){
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeTabBarController")! as! UITabBarController
        self.navigationController?.presentViewController(detailController, animated: true,completion:nil)
    }
    
    

    
    //Reset textfield
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if textField.text == "TOP" || textField.text == "BOTTOM"{
            textField.text = ""
        }
        if textField.isEqual(bottomTextField){
            self.subscribeToKeyboardNotifications()
        }
    }



    //keyboard related
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(bottomTextField){
            self.unsubscribeFromKeyboardNotifications()
        }
        return true
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if(keyboardHidden ){ //If the keyboard was not hidden.(e.g. we change the type of the keyboard on currently displayed keyboard view) there's no need to change the origin.
            self.view.frame.origin.y -= getKeyboardHeight(notification)
            keyboardHidden = false
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(!keyboardHidden){//If the keyboard was hidden.(e.g. we change the type of the keyboard on currently displayed keyboard view) there's no need to change the origin.
            self.view.frame.origin.y = 0
            keyboardHidden = true
        }
    }


    
    //Generater meme
    func generateMemedImage() -> UIImage {
        
        
        //Toolbar hidden
        hide(true,animated: false)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Toolbar visible
        hide(false,animated: false)
    
        return memedImage
    }
    
    


    func save() {
        //Create the meme
        memedImage = generateMemedImage()
        var meme = Meme(topText:topTextField.text!, bottomText: bottomTextField.text!,  image: imagePickerView.image!,  memedImage: memedImage)
        self.meme = meme
        (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
    }
    
    
    
    
    //share the image
    func share(){
        save()
        //Share to Facebook, Flickr, Twitter, SMS or CameraRoll
        let objectsToShare = [UIActivityTypePostToFacebook,UIActivityTypePostToFlickr,UIActivityTypePostToTwitter,UIActivityTypeMessage,UIActivityTypeSaveToCameraRoll]
        let activity = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activity.completionWithItemsHandler = { (activity, success, items, error) in
                let detailController = self.storyboard!.instantiateViewControllerWithIdentifier("MemeTabBarController")! as! UITabBarController
            
            self.navigationController!.presentViewController(detailController, animated: true, completion: nil)
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.navigationController?.setToolbarHidden(true, animated: false) //Set the toolbar hidden so as to enable the table view's toolbar.
            
            //Reset Editor View.
            let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            applicationDelegate.editorMeme = Meme(topText: "TOP", bottomText: "BOTTOM", image: UIImage(), memedImage: UIImage())
        }

        self.presentViewController(activity, animated: true, completion:nil)
        
    }
    
    
    
    

    
    //hide toolbar
    func tapped(){
        toolbarHidden = !toolbarHidden
    }
    
    func detectPan(recognizer:UIPanGestureRecognizer) {
        var translation  = recognizer.translationInView(self.imagePickerView)
        self.imagePickerView.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // Remember original location
        super.touchesBegan(touches, withEvent: event)
        lastLocation = self.imagePickerView.center
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        lastLocation = self.imagePickerView.center
    }
    
    //Update the location(from a pan gesture)
    func updateLocation(){
        self.imagePickerView.center = lastLocation //Update the location(from a pan gesture)
    }
    

    //hide toolbar and navigation bar
    func hide(flag:Bool,animated:Bool){
        self.navigationController?.setNavigationBarHidden(flag, animated: animated)
        self.navigationController?.setToolbarHidden(flag, animated: animated)
        self.updateLocation()
    }
    
   
    
}