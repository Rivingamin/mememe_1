//
//  DetailViewController.swift
//  ImagePicker
//
//  Created by Riving Amin on 20/05/15.
//  Copyright (c) 2015 Riving Amin. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController,UINavigationControllerDelegate,UIGestureRecognizerDelegate {
    var meme: Meme!
    var editButton:UIBarButtonItem!
    
    var deleteButton:UIBarButtonItem!
    
    var flexiblespace:UIBarButtonItem!
    
    let tapRec = UITapGestureRecognizer()
    
    var hideToolbar = false
    
    @IBOutlet weak var detailImage: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tapRec.addTarget(self, action: "tapped")
        tapRec.delegate = self
        view.addGestureRecognizer(tapRec)
        
      
        flexiblespace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        
        
        //Edit the image
        editButton = UIBarButtonItem(title: "Edit", style: .Done, target: self, action: "editImage")
        
        
        
        //Delete the image
        deleteButton = UIBarButtonItem(title: "Delete", style: .Done, target: self, action: "deleteImage")

        self.navigationItem.rightBarButtonItems = [editButton,deleteButton]

        self.detailImage.image = meme.memedImage

    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "edit"{
            if let a = segue.destinationViewController as? EditorViewController{
                let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
                applicationDelegate.editorMeme = self.meme
                }
            }
    }
    

    
    
    //Edit and delete functions
    func editImage(){
        self.dismissViewControllerAnimated(true, completion: nil)
        self.performSegueWithIdentifier("edit", sender: self)
    }
    
    
    

    func deleteImage(){
        let applicationDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
        applicationDelegate.memes.removeLast()

        self.navigationController?.popViewControllerAnimated(true)
        
    }

    
    //Hide functions

    func tapped(){
        if(hideToolbar){
            hide(false,animated: true)
            hideToolbar = false
        }else{
            hide(true,animated: true)
            hideToolbar = true
        }
    }

 
   
    func hide(flag:Bool,animated:Bool){
        self.navigationController?.setNavigationBarHidden(flag, animated: animated)
        setTabBarVisible(!flag, animated: true)
    }
    

    func setTabBarVisible(visible:Bool, animated:Bool) {
        
      
        if (tabBarIsVisible() == visible) { return }
        
   
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
     
        let duration:NSTimeInterval = (animated ? 0.3 : 0.0)
        
       
        if frame != nil {
            UIView.animateWithDuration(duration) {
                self.tabBarController?.tabBar.frame = CGRectOffset(frame!, 0, offsetY!)
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return self.tabBarController?.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame)
    }



}
