//
//  ViewController.swift
//  Gridy
//
//  Created by Michael Gresham on 18/04/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class MenuViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func pickButton(_ sender: Any) {
        processPicked(image: randomImage())
        performSegue(withIdentifier: "editorSegue", sender: self)
    }
    @IBAction func cameraButton(_ sender: Any) {
        displayCamera()
    }
    @IBAction func libraryButton(_ sender: Any) {
        displayLibrary()
    }

    let imagePickerController = UIImagePickerController()
    var randomImages = [UIImage]()
    var creation = Creation.init()

    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        config()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    func config() {
        imagePickerController.delegate = self
        randomImages = creation.collectRandomImageSet()
    }


    //MARK: Access to camera and library
    func displayCamera() {
        // Display device camera, checking if their is permisson, and display any errors to user
        let sourceType = UIImagePickerController.SourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            switch status {
            case .notDetermined:
                // User has not previously given permission
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {(granted) in
                    if granted {
                        // User has given permission
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        // We don't have permisson
                        self.present(AlertController.init().troubleAlertContoller(message: .cameraPermisson), animated: true)
                    }
                })
            case .authorized:
                // User has previously given permission
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                // User has denied us access
                present(AlertController.init().troubleAlertContoller(message: .cameraPermisson), animated: true)
            @unknown default:
                fatalError(Messages.cameraPermisson.rawValue)
            }
        }
        else {
            present(AlertController.init().troubleAlertContoller(message: .cameraError), animated: true)
        }
    }

    func displayLibrary() {
        // Display photo library, checking for permission, and display any errors to user
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .notDetermined:
                // User has not previously given permission
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus == .authorized {
                        // User has given permission
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        // We don't have permisson
                        self.present(AlertController.init().troubleAlertContoller(message: .libraryPermission), animated: true)
                    }
                })
            case .authorized:
                // User has previously given permission
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                // User has denied us access
                present(AlertController.init().troubleAlertContoller(message: .libraryPermission), animated: true)
            @unknown default:
                self.presentImagePicker(sourceType: sourceType)
            }
        }
        else {
            present(AlertController.init().troubleAlertContoller(message: .libraryError), animated: true)
            }
    }

    //MARK: image picking
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        // Present Image Picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    func randomImage() -> UIImage {
        // Function to return random image
        randomImages = randomImages.shuffled()
        while creation.image == randomImages.first{
            //check image is not the same as current image
            randomImages = randomImages.shuffled()
        }
        return randomImages.first!
    }

    func processPicked(image: UIImage?) {
        if let newImage = image {
            self.creation.image = newImage
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Once user has selected image from image picking options, perform segue to edit image
        let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        processPicked(image: newImage)
        dismiss(animated: true, completion: { () -> Void in
            self.performSegue(withIdentifier: "editorSegue", sender: self)
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
// MARK: Segue Controls
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Send selected image to editor segue
        if segue.identifier == "editorSegue" {
            let editorViewController = segue.destination as! EditorViewController
            editorViewController.incomingImage = creation.image
        }
    }

    @IBAction func unwindToMenu(_ unwindSegue: UIStoryboardSegue) {}
}


