//
//  ViewController.swift
//  MergeVideoWithIMage
//
//  Created by Ajaynath MS on 13/05/18.
//  Copyright © 2018 ajay. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    @IBOutlet weak var progress: UIActivityIndicatorView!
    var imagePickerController = UIImagePickerController()
    var videoURL: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        progress.isHidden=true;
    }


    @IBAction func videoSelect(_ sender: UIButton) {
        loadPicker()
    }
  
    @IBAction func OnExport(_ sender: UIButton) {
        exportImage()
        
    }
    @IBAction func onAddText(_ sender: AnyObject) {
        //let footerTextValue=footerText.text;
      //  var attributedString = NSMutableAttributedString(string: footerTextValue!)

        imageView.image=imageFromTextView(text: footerText.text!)    }
 
    @IBOutlet var footerText: UITextField!
   
       
    @IBAction func onimageSelect(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            ///print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    @IBOutlet var imageView: UIImageView!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //Dispose of any resources that can be recreated.
    }
   
    var imagePicker = UIImagePickerController()
    
    func loadPicker()
    {
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as NSString as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let mediaType = info[UIImagePickerControllerMediaType] as? String {
            
            if mediaType  == "public.image" {
                imageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage
            }
            
            if mediaType == "public.movie" {
                videoURL = info[UIImagePickerControllerMediaURL] as? URL
                
            }
        }
        // print("videoURL:\(String(describing: videoURL))")
        self.dismiss(animated: true, completion: nil)
        // exportImage()
    }
    
    func imageFromTextView(text: String) -> UIImage {
        
        let labelView = UILabel(frame: imageView.frame)
        labelView.backgroundColor=UIColor.black
        //adjust frame to change position of water mark or text
        labelView.text = text
        labelView.textColor=UIColor.white
        labelView.textAlignment=NSTextAlignment.center
        
        imageView.addSubview(labelView)
        UIGraphicsBeginImageContext(imageView.frame.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let watermarkedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return watermarkedImage!
    }
    func exportImage()
    {
        if(videoURL==nil)
        {
            self.showToast(message: "Select video first")

        }
        else
        {
            processVideoWithWatermark(url:videoURL!)
            
        }
    }
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 175, y: self.view.frame.size.height-100, width: 350, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 11.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
        })
    }
    
    func processVideoWithWatermark(url: URL) {
        let mergeConfig=MergeConfiguration(frameRate: 30, directory: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], quality: Quality.high,placement: Placement.custom(x: 200, y: 40, size: CGSize(width: 200, height: 40)))
        let merge = Merge(config: mergeConfig)
        progress.isHidden=false;
        progress.startAnimating()
        
        imageView.image=imageFromTextView(text: footerText.text!)
        merge.overlayVideo( video: AVAsset(url: videoURL!), overlayImage: imageView.image, completion:
            { url in
                print("videoURLnewwww:\(String(describing: url))")
                ALAssetsLibrary().writeVideoAtPath(toSavedPhotosAlbum: url, completionBlock: nil)
                self.progress.isHidden=true;
                self.progress.stopAnimating()
                self.showToast(message: "Video saved to gallery!!!")
                
                // Video done exporting
        }) { progress in
            // progress of video export
        }
        
                
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    

   }

