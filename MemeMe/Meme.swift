//
//  ViewController.swift
//  ImagePicker
//
//  Created by Riving Amin on 15/05/15.
//  Copyright (c) 2015 Riving Amin. All rights reserved.
//

import Foundation
import UIKit
class Meme{
    var topText:String!
    var bottomText:String!
    var image: UIImage!
    var memedImage: UIImage!

    init(let topText:String,let bottomText:String, let image:UIImage, let memedImage:UIImage){
        self.topText = topText
        self.bottomText = bottomText
        self.image = image
        self.memedImage = memedImage
    }
    
}