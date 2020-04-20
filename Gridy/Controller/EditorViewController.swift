//
//  EditorViewController.swift
//  Gridy
//
//  Created by Michael Gresham on 18/04/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVFoundation

class EditorViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var creationImageView: UIImageView!
    @IBOutlet weak var hiddenCreationImageView: UIImageView!
    @IBOutlet weak var gridImageView: UIImageView!
    @IBOutlet weak var creationFrame: UIView!
    @IBOutlet weak var difficultySlider: UISlider!
    
    
    @IBAction func startButton(_ sender: Any) {
        creation.image = composeCreationImage()
        preparePuzzleImages()
        performSegue(withIdentifier: "puzzleSegue", sender: self)
    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        if difficultySlider.value == 6 {
            difficulty = 5
        } else {
        difficulty = Int(difficultySlider.value)
        }
        setDifficulty()
    }
    
    var incomingImage: UIImage?
    var creation = Creation.init()
    var initalImageViewOffset = CGPoint()
    let defaults = UserDefaults.standard
    var difficulty = 4
    var puzzleImages = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        config()
    }
    
    func config() {
        setImage()
        setDifficulty()
        difficultySlider.value = Float(difficulty)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveImageView(_sender:)))
        gridImageView.addGestureRecognizer(panGestureRecognizer)
        panGestureRecognizer.delegate = self
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(scaleImageView(_sender:)))
        gridImageView.addGestureRecognizer(pinchGestureRecognizer)
        pinchGestureRecognizer.delegate = self
        
        let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateImageView(_sender:)))
        gridImageView.addGestureRecognizer(rotationGestureRecognizer)
        rotationGestureRecognizer.delegate = self
        
    }
    
    func setImage() {
        if let image = incomingImage {
            creationImageView.image = image
            hiddenCreationImageView.image = image
        }
    }
    
    func setDifficulty() {
        switch difficulty {
        case 3:
            self.animateImage(newImage: UIImage.init(named:"3x3grid")!)
        case 4:
            self.animateImage(newImage: UIImage.init(named:"4x4grid")!)
        case 5:
            self.animateImage(newImage: UIImage.init(named:"5x5grid")!)
        default:
            self.animateImage(newImage: UIImage.init(named:"5x5grid")!)
        }
    }
    
    func animateImage (newImage: UIImage){
        UIView.transition(with: self.gridImageView, duration: 1.0, options: .transitionCrossDissolve, animations: {
        self.gridImageView.image = newImage
    }, completion: nil)
    }
    
    @objc func moveImageView(_sender: UIPanGestureRecognizer){
        print("moving")
        let translation = _sender.translation(in: creationImageView.superview)
        
        if _sender.state == .began {
            initalImageViewOffset = creationImageView.frame.origin
        }
        
        let position = CGPoint (x: translation.x + initalImageViewOffset.x - creationImageView.frame.origin.x, y: translation.y + initalImageViewOffset.y - creationImageView.frame.origin.y)
        
        creationImageView.transform = creationImageView.transform.translatedBy(x: position.x, y: position.y)
        hiddenCreationImageView.transform = hiddenCreationImageView.transform.translatedBy(x: position.x, y: position.y)
        
    }
    @objc func scaleImageView(_sender: UIPinchGestureRecognizer){
        print("scaling")
        creationImageView.transform = creationImageView.transform.scaledBy(x: _sender.scale, y: _sender.scale)
        _sender.scale = 1
        hiddenCreationImageView.transform = creationImageView.transform.scaledBy(x: _sender.scale, y: _sender.scale)
        _sender.scale = 1
    }
    @objc func rotateImageView(_sender: UIRotationGestureRecognizer){
        print("rotating")
        creationImageView.transform = creationImageView.transform.rotated(by: _sender.rotation)
        _sender.rotation = 0
        hiddenCreationImageView.transform = creationImageView.transform.rotated(by: _sender.rotation)
        _sender.rotation = 0
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer:UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view != gridImageView {
            return false
        }
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    func composeCreationImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(creationFrame.bounds.size, false, 0 )
        creationFrame.drawHierarchy(in: creationFrame.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    func preparePuzzleImages() {
        puzzleImages.removeAll()
        puzzleImages = slice(screenshot: creation.image, with: difficulty)
    }
    
    func slice(screenshot: UIImage, with difficulty: Int) -> [UIImage] {
        let width = screenshot.size.width
        let height = screenshot.size.height
        
        let puzzleImageWidth = width / CGFloat(difficulty)
        let puzzleImageHeight = height / CGFloat(difficulty)
        
        let scale = screenshot.scale
        let cgImage = screenshot.cgImage
        var images = [UIImage]()
        
        var adjustedHeight = puzzleImageHeight
        var y = CGFloat(0)
        
        for row in 0 ..< difficulty {
            if row == (difficulty - 1) {
                adjustedHeight = height - y
            }
            var adjustedWidth = puzzleImageWidth
            var x = CGFloat(0)
            for column in 0 ..< difficulty {
                if column == (difficulty - 1) {
                    adjustedWidth = width - x
                }

                let origin = CGPoint(x: x * scale, y: y * scale)
                let size = CGSize(width: adjustedWidth * scale, height: adjustedHeight * scale)
                let puzzleImage = cgImage?.cropping(to: CGRect(origin: origin, size: size))!
                images.append(UIImage(cgImage: puzzleImage!, scale: scale, orientation: .up))
                x += puzzleImageWidth
            }
            y += puzzleImageHeight
        }
        print(images.count)
        return images
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "puzzleSegue" {
                let puzzleViewController = segue.destination as! PuzzleViewController
                puzzleViewController.piecesCVImages = puzzleImages
        }
    }

}
