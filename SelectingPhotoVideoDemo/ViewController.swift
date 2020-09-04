//
//  ViewController.swift
//  SelectingPhotoVideoDemo
//
//  Created by Mangesh Shinde on 04/09/20.
//  Copyright © 2020 Mangesh Shinde. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var btnSelectImage: UIButton!
    
    @IBAction func btnClicked(_ sender: UIButton) {
        showalertActionForCamera()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setBtnEffect(givenView: btnSelectImage)
        self.setUpUI()
    }
    
    func setUpUI() {
        imgView.layer.shadowColor = UIColor.black.cgColor
        imgView.layer.shadowOffset = CGSize.zero//CGSize(width: 5.0, height: 5.0)//CGSize.zero
        imgView.layer.shadowRadius = 10.0
        imgView.layer.shadowOpacity = 1
//        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 25

        
//        self.imgView.addShadow(shadowColor: .black, offSet: CGSize(width: 2.6, height: 2.6), opacity: 0.8, shadowRadius: 10.0, cornerRadius: 20.0, corners: [.topRight, .topLeft, .bottomLeft, .bottomRight], fillColor: .clear)

    }
    
    func setBtnEffect(givenView:UIButton){
        // layer effect
        givenView.layer.cornerRadius = 25
        givenView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        givenView.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)//CGSize.zero
        givenView.layer.shadowOpacity = 1
        givenView.backgroundColor = UIColor.darkGray
        givenView.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 18)
        givenView.titleLabel?.textColor = UIColor.white
    }
    //MARK:- Camera and gallery permission
    func showalertActionForCamera() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        // create an action
        let cameraAction: UIAlertAction = UIAlertAction(title: "Take From Camera", style: .default) { action -> Void in
            self.checkPermissionCamera()
            print("First Action pressed")
        }
        let galleryAction: UIAlertAction = UIAlertAction(title: "Select From Gallery", style: .default) { action -> Void in
            self.GalleryPermission()
            print("Photo Gallery Button pressed")
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        cameraAction.setValue(UIColor.black, forKey: "titleTextColor")
        galleryAction.setValue(UIColor.black, forKey: "titleTextColor")
        cancelAction.setValue(UIColor.black, forKey: "titleTextColor")
        actionSheetController.addAction(cameraAction)
        actionSheetController.addAction(galleryAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true, completion: nil)
    }
    func checkPermissionCamera() {
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            print("Already Authorized")
            self.openCamera()
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    DispatchQueue.main.async {
                        self.openCamera()
                    }
                    print("If Granted")
                } else {
                    print("Not Granted")
                    DispatchQueue.main.async {
                        self.alertToShowSetting(from: "Cam")
                    }
                }
            })
        }
    }
    func GalleryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        if (status == PHAuthorizationStatus.authorized) {
            DispatchQueue.main.async {
                self.openGallary()
            }
        }else if (status == PHAuthorizationStatus.denied) {
            DispatchQueue.main.async {
                self.alertToShowSetting(from: "Gal")
            }
        }else if (status == PHAuthorizationStatus.notDetermined) {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    DispatchQueue.main.async {
                        self.openGallary()
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertToShowSetting(from: "Gal")
                    }
                }
            })
        }
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
            self.gotoOpenSetting()
        }
    }
    
    
}



extension ViewController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func openCamera() {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            self.imagePicker.delegate = self
//            imagePicker.allowsEditing = true
            imagePicker.showsCameraControls = true
            //            appIsTakingPhoto = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            DispatchQueue.main.async {
                self.openGallary()
            }
        }
    }
    
    func openGallary() {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        self.imgView.image = image
        
        dismiss(animated: false)
    }
    
    func alertToShowSetting(from: String) {
        self.navigationController?.dismiss(animated: true, completion: nil)
        var msg = ""
        if from == "Gal" {
            msg = "Wandafree does not have access to your photos. To enable access, tap Settings and turn on Photos."
        } else {
            msg = "Wandafree does not have access to your camera. To enable access, tap Settings and turn on Camera."
        }
        let alertController = UIAlertController(title: msg, message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Settings", style: UIAlertAction.Style.default) {
            UIAlertAction in
            self.gotoOpenSetting()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
            UIAlertAction in
        }
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func gotoOpenSetting() {
        let settings: String = UIApplication.openSettingsURLString
        let settingsURL = URL(string: settings)
        UIApplication.shared.open(settingsURL!, options: [:],
                                  completionHandler: {
                                    (success) in
                                    print("Open  \(success)")
        })
    }
}


extension UIView {
    
    func addShadow(shadowColor: UIColor, offSet: CGSize, opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, corners: UIRectCorner, fillColor: UIColor = .white) {
        
        let shadowLayer = CAShapeLayer()
        let size = CGSize(width: cornerRadius, height: cornerRadius)
        let cgPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: size).cgPath //1
        shadowLayer.path = cgPath //2
        shadowLayer.fillColor = fillColor.cgColor //3
        shadowLayer.shadowColor = shadowColor.cgColor //4
        shadowLayer.shadowPath = cgPath
        shadowLayer.shadowOffset = offSet //5
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowRadius = shadowRadius
        self.layer.addSublayer(shadowLayer)
    }
}
