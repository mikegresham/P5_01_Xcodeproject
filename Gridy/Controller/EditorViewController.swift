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
        difficultySlider.value = 4.5
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
        let translation = _sender.translation(in: gridImageView.superview)
        
        if _sender.state == .began || _sender.state == .changed {
            creationImageView.center = CGPoint(x: creationImageView.center.x + translation.x, y: creationImageView.center.y + translation.y)
            _sender.setTranslation(CGPoint.zero, in: creationImageView)
            hiddenCreationImageView.center = CGPoint(x: hiddenCreationImageView.center.x + translation.x, y: hiddenCreationImageView.center.y + translation.y)
            _sender.setTranslation(CGPoint.zero, in: hiddenCreationImageView)
        }
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
        if gestureRecognizer is UIPanGestureRecognizer || otherGestureRecognizer is UIPanGestureRecognizer {
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
        let width: CGFloat
        let height: CGFloat

        switch screenshot.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            width = screenshot.size.height
            height = screenshot.size.width
        default:
            width = screenshot.size.width
            height = screenshot.size.height
        }

        let tileWidth = Int(width / CGFloat(difficulty))
        let tileHeight = Int(height / CGFloat(difficulty))

        let scale = Int(screenshot.scale)
        var images = [UIImage]()

        let cgImage = screenshot.cgImage!

        var adjustedHeight = tileHeight

        var y = 0
        for row in 0 ..< difficulty {
            if row == (difficulty - 1) {
                adjustedHeight = Int(height) - y
            }
            var adjustedWidth = tileWidth
            var x = 0
            for column in 0 ..< difficulty {
                if column == (difficulty - 1) {
                    adjustedWidth = Int(width) - x
                }
                let origin = CGPoint(x: x * scale, y: y * scale)
                let size = CGSize(width: adjustedWidth * scale, height: adjustedHeight * scale)
                let tileCgImage = cgImage.cropping(to: CGRect(origin: origin, size: size))!
                images.append(UIImage(cgImage: tileCgImage, scale: screenshot.scale, orientation: screenshot.imageOrientation))
                x += tileWidth
            }
            y += tileHeight
        }
        return images
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "puzzleSegue" {
                let puzzleViewController = segue.destination as! PuzzleViewController
                puzzleViewController.piecesCVImages = puzzleImages
                puzzleViewController.creation = creation
        }
    }

}
