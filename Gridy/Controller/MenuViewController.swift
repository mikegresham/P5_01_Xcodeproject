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

    func config() {
        imagePickerController.delegate = self
        collectRandomImageSet()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editorSegue" {
            let editorViewController = segue.destination as! EditorViewController
            editorViewController.incomingImage = creation.image
        }
    }

    //MARK: Access to camera and library
    func displayCamera() {
        let sourceType = UIImagePickerController.SourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            let noPermissionMessage = "Looks like Gridy doesn't have access to your camera. Please use the Settings app on your device to permit Gridy accessing your camera"
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {(granted) in
                    if granted {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(title: "Oops...", message: noPermissionMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(title: "Oops...", message: noPermissionMessage)
            @unknown default:
                fatalError(noPermissionMessage)
            }
        }
        else {
            troubleAlert(title: "Oops...", message: "Sincere apologies, it looks like we can't access your camera at this time")
        }
    }

    func displayLibrary() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionStatusMessage = "Looks like Gridy haven't access to your photos. Please use the Settings app on your device to permit Gridy accessing your library"
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(title: "Oops", message: noPermissionStatusMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(title: "Oops...", message: noPermissionStatusMessage)
            @unknown default:
                self.presentImagePicker(sourceType: sourceType)
           
            }
        }
        else {
            troubleAlert(title: "Oops...", message: "Sincere apologies, it looks like we can't access your photo library at this time")
        }
    }

    //MARK: image picking
    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }

    func troubleAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true)
    }

    func randomImage() -> UIImage {
        let randomNumber = Int.random(in: 0 ..< randomImages.count)
        return randomImages[randomNumber]
    }

    func collectRandomImageSet() {
        randomImages.removeAll()
        let imageNames = ["lake", "paint", "lights", "railway", "road"]
        for i in 0 ..< imageNames.count {
                randomImages.append(UIImage.init(named: imageNames[i])!)
        }
    }

    func processPicked(image: UIImage?) {
        if let newImage = image {
            self.creation.image = newImage
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("hello")
        let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        processPicked(image: newImage)
        dismiss(animated: true, completion: { () -> Void in
            self.performSegue(withIdentifier: "editorSegue", sender: self)
        })
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    @IBAction func unwindToMenu(_ unwindSegue: UIStoryboardSegue) {}
}


