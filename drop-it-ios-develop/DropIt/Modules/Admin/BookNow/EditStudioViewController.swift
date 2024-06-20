//
//  EditStudioViewController.swift
//  DropIt
//
//  Created by Vijay Rathore on 01/11/22.
//

import UIKit


import UIKit
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import CropViewController
import FirebaseStorage

class EditStudioViewController : UIViewController {
    
    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var studioImage: UIImageView!
    
    @IBOutlet weak var studioName: UITextField!
    
    @IBOutlet weak var studiLocation: UITextField!
    
    @IBOutlet weak var price: UITextField!
    
    @IBOutlet weak var addBtn: UIButton!
    
    var studio : StudioModel?
    var downloadURL : String = ""
    
    var isMondaySelected = false
    var isTuesdaySelected = false
    var isWednesdaySelected = false
    var isThursdaySelected = false
    var isFridaySelected = false
    var isSaturdaySelected = false
    var isSundaySelected = false
    
    override func viewDidLoad() {
        
        
        guard let studio = studio else {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
            return
        }
        
        
        
        studioImage.isUserInteractionEnabled = true
        studioImage.layer.cornerRadius = 8
        studioImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(studioImageClicked)))
        if let image = studio.image, image != "" {
            downloadURL = image
            studioImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"))
        }
        
        
        
        studioName.delegate = self
        studiLocation.delegate = self
        price.delegate = self
        
        studioName.text = studio.name ?? ""
        studiLocation.text = studio.address ?? ""
        price.text = "\(studio.price ?? 0)"
        
  
        addBtn.layer.cornerRadius = 8
        
        backView.layer.cornerRadius = 8
        backView.isUserInteractionEnabled  = true
        backView.dropShadow()
        backView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backBtnClicked)))
        
 
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    

    
    @objc func studioImageClicked(){
        chooseImageFromPhotoLibrary()
    }
    
    func chooseImageFromPhotoLibrary(){
        
        let image = UIImagePickerController()
        image.delegate = self
        image.title = title
        image.sourceType = .photoLibrary
        self.present(image,animated: true)
    }
    
    @objc func backBtnClicked(){
        self.dismiss(animated: true)
    }
    

    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @IBAction func addBtnClicked(_ sender: Any) {
        
        let sName = studioName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sLocation = studiLocation.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let sPrice = price.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if downloadURL == "" {
            self.showToast(message: "Upload Studio Image")
            return
        }
        if sName == "" {
            self.showToast(message: "Enter Studio Name")
            return
        }
        if sLocation == "" {
            self.showToast(message: "Enter Studio Location")
            return
        }
        if sPrice == "" {
            self.showToast(message: "Enter Per Hour Price")
            return
        }
        else {
            progressHUDShow(text: "Updating...")
            self.studio!.image = downloadURL
            self.studio!.name = sName
            self.studio!.address = sLocation
            self.studio!.price = Int(sPrice ?? "1")!
            try? Firestore.firestore().collection("Studios").document(self.studio!.id ?? "123").setData(from: self.studio!,merge : true,completion: { error in
                self.progressHUDHide()
                if error == nil {
                    self.showToast(message: "Studio Updated")
                    DispatchQueue.main.async {
                        let seconds = 2.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                            self.dismiss(animated: true)
                        }
                    }
                }
                else {
                    self.showMyError(error!.localizedDescription)
                }
            })
        }
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    

  
    
}

extension EditStudioViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate,CropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.originalImage] as? UIImage {
            
            
            
            self.dismiss(animated: true) {
                
                let cropViewController = CropViewController(image: editedImage)
                cropViewController.title = picker.title
                cropViewController.delegate = self
                cropViewController.customAspectRatio = CGSize(width: 1  , height: 1)
                cropViewController.aspectRatioLockEnabled = true
                cropViewController.aspectRatioPickerButtonHidden = true
                self.present(cropViewController, animated: true, completion: nil)
            }
            
            
            
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        self.progressHUDShow(text: "Uploading...")
        
        studioImage.image = image
        
        
     
        uploadImageOnFirebase(storeId: studio!.id ?? "123"){ downloadURL in
            
            self.progressHUDHide()
            self.downloadURL = downloadURL
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func uploadImageOnFirebase(storeId : String,completion : @escaping (String) -> Void ) {
        
        let storage = Storage.storage().reference().child("Studios").child(storeId).child("\(storeId).png")
        var downloadUrl = ""
        
        var uploadData : Data!
        
        
        uploadData = (self.studioImage.image?.jpegData(compressionQuality: 0.4))!
        
        
        
        storage.putData(uploadData, metadata: nil) { (metadata, error) in
            
            if error == nil {
                storage.downloadURL { (url, error) in
                    if error == nil {
                        downloadUrl = url!.absoluteString
                    }
                    completion(downloadUrl)
                    
                }
            }
            else {
                completion(downloadUrl)
            }
            
        }
    }
}

