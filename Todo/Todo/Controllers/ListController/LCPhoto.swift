//
//  LCPhoto.swift
//  Todo
//
//  Created by Dante Kim on 1/13/21.
//  Copyright © 2021 Alarm & Calm. All rights reserved.
//

import UIKit
import Photos
import TOCropViewController

extension ListController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, TOCropViewControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       picker.dismiss(animated: true, completion: nil)
       guard let image = info[.originalImage] as? UIImage else {
           fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
       }
      

        if !nameTaken2 {
            let cropViewController = TOCropViewController(image: image)
            cropViewController.delegate = self
//            present(cropViewController, animated: true, completion: nil)
            cropViewController.presentAnimatedFrom(self, view: nil, frame: view.bounds, setup: nil, completion: nil)
        }
   
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
            // 'image' is the newly cropped version of the original image
        if saveImage(image: image, name: listName) {
            cropViewController.dismiss(animated: true, completion: nil)
           let img = getSavedImage(named: listName)
            backgroundImage.image = img
            selectedImage = img!
            creating = true
            configureNavBar()
            createTappedDone()
            photoSelected = true
            stabilize = true
            bigTextField.becomeFirstResponder()
            print(self.customizeListView.frame.origin.y)
            return
        }
    }


    func saveImage(image: UIImage, name: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
 
        
        do {
            try data.write(to: directory.appendingPathComponent(name)!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func pickImageCallback(_ image: UIImage) {
        
    }
    
      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
         keyboard2 = false
        
          picker.dismiss(animated: true, completion: nil)
      }
    func uploadPhoto() {
        if listObject.name == "" {
            let results = uiRealm.objects(ListObject.self)
            nameTaken2 = false
            stabilize = true
            for result in results {
                if result.name == bigTextField.text! {
                    nameTaken2 = true
                    //bug happens when I call this alert controlelr
                    let alertController = UIAlertController(title: "Please select a unique List Name First", message: "", preferredStyle: UIAlertController.Style.alert)
                    let okayAction = UIAlertAction(title: "Okay", style: UIAlertAction.Style.default) { [self] (action) in
                        print(stabilize, self.customizeListView.frame.origin.y, "yolo")
                        creating = true
                        return
                    }

                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            listName = bigTextField.text!
        } else {
            listName = listObject.name
        }
        if !nameTaken2 {
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                imagePicker.delegate = self
                imagePicker.sourceType = .photoLibrary
                imagePicker.allowsEditing = false
                if !nameTaken2 {
                    keyboard2 = false
                }
                present(imagePicker, animated: true, completion: nil)
            }
        }
    }
}
