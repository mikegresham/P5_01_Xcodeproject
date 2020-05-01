//
//  PuzzleViewController.swift
//  Gridy
//
//  Created by Michael Gresham on 18/04/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class PuzzleViewController: UIViewController {
    
    // MARK: Global Variables
    var creation = Creation.init()
    var piecesCVImages = [UIImage]()
    var correctOrderImages = [UIImage]()
    var boardCVImages = [UIImage]()
    var columns = Int()
    var selectedIndexPath = IndexPath()
    var totalMoves: Int = 0
    var correctMoves: Int = 0
    var score: Int = 0
    var consecutiveCorrectMoves: Int = 0
    var consecutiveIncorrectMoves: Int = 0
    var soundIsOn: Bool = true
    var audioPlayer = AVAudioPlayer()

    @IBOutlet weak var scoreChangeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var movesLabel: UILabel!
    @IBOutlet weak var lookupImageView: UIImageView!
    @IBOutlet weak var piecesCollectionView: UICollectionView!
    @IBOutlet weak var boardCollectionView: UICollectionView!
    @IBOutlet weak var piecesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var boardCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var muteButton: UIButton!

    @IBAction func muteButtonAction(_ sender: Any) {
        if soundIsOn == true {
            soundIsOn = false
        } else {
            soundIsOn = true
        }
        updateMute()
    }

    // MARK: Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    func config() {
        muteButton.setImage(UIImage(systemName: "speaker.fill"), for: .normal)
        muteButton.setImage(UIImage(systemName: "speaker.slash.fill"), for: .selected)
        
        // Set Delegates for Puzzle View Controller
        piecesCollectionView.dataSource = self
        piecesCollectionView.delegate = self
        boardCollectionView.dataSource = self
        boardCollectionView.delegate = self
        piecesCollectionView.dragDelegate = self
        boardCollectionView.dragDelegate = self
        piecesCollectionView.dropDelegate = self
        boardCollectionView.dropDelegate = self
        piecesCollectionView.dragInteractionEnabled = true
        boardCollectionView.dragInteractionEnabled = true

        // Additional Setup
        correctOrderImages = piecesCVImages
        piecesCVImages = piecesCVImages.shuffled()
        lookupImageView.image = creation.image
        lookupImageView.isHidden = true
        scoreChangeLabel.isHidden = true
        updateScore()
        addPlaceHolderImages()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    func addPlaceHolderImages() {
        if piecesCVImages.count == 25 {
            columns = 7
            piecesCVImages.append(UIImage.init(named: "blank")!)
            piecesCVImages.append(UIImage.init(named: "blank")!)
            piecesCVImages.append(UIImage.init(named: "Gridy-lookup")!)
        } else if piecesCVImages.count == 16 {
            columns = 6
            piecesCVImages.append(UIImage.init(named: "blank")!)
            piecesCVImages.append(UIImage.init(named: "Gridy-lookup")!)
        } else {
            columns = 5
            piecesCVImages.append(UIImage.init(named: "Gridy-lookup")!)
        }
        for _ in 0 ..< correctOrderImages.count {
            boardCVImages.append(UIImage.init(named: "blank")!)
        }
        piecesCollectionView.reloadData()
        boardCollectionView.reloadData()
    }
    func updateMute() {
        if soundIsOn == true {
            muteButton.isSelected = false
        } else {
            muteButton.isSelected = true
        }
    }
    
    // MARK: Scoring
    func updateScore() {
        var increment = 0
        // example: if 3rd correct move in a row the increment would be 1+2+3 = 6
        if consecutiveCorrectMoves > 0 {
            for i in 1 ... consecutiveCorrectMoves {
                increment += i
            }
        // the opposite applies for wrong moves: -1-2-3 = -6
        } else if consecutiveIncorrectMoves > 0 {
            for i in 1 ... consecutiveIncorrectMoves {
                increment -= i
            }
        }
        // score can't drop below zero
        if (score + increment) >= 0 {
            score += increment
        } else {
            increment = score * -1
            score = 0
        }
        
        // display the change in score
        scoreChangeLabel.isHidden = false
        scoreLabel.text = String(score)
        movesLabel.text = String(totalMoves)
        
        if increment > 0 {
            scoreChangeLabel.text = "+\(increment)"
            scoreChangeLabel.textColor = UIColor.init(red: 136/255, green: 212/255, blue: 152/255, alpha: 1)
        } else if increment < 0 {
            scoreChangeLabel.text = String(increment)
            scoreChangeLabel.textColor = UIColor.red
        }else {
        scoreChangeLabel.text = "0"
        scoreChangeLabel.textColor = UIColor.black
        }
        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.hideScoreChangeLabel), userInfo: nil, repeats: false)
    }
    @objc func hideScoreChangeLabel() {
        scoreChangeLabel.isHidden = true
    }
    
    // MARK: Gameover
    func endGame() {
        let endGameAlert = UIAlertController(title: "Congratulations!", message: "Score: \(score)\nMoves: \(totalMoves)", preferredStyle: .alert)
        let newGame = UIAlertAction(title: "New Game", style: .default) {(action) in
            self.performSegue(withIdentifier: "Menu", sender: nil)
        }
        endGameAlert.addAction(newGame)
        let share = UIAlertAction(title: "Share", style: .default) {(action) in
            self.displaySharingOptions()
        }
        endGameAlert.addAction(share)
        let cancel = UIAlertAction(title: "Cancel", style: .destructive)
        endGameAlert.addAction(cancel)
        present(endGameAlert, animated: true)
    }
    
    func displaySharingOptions(){
        let note = "I completed this puzzle in \(totalMoves) with a score of \(score)"
        let image = creation.image
        let items = [note as Any, image as Any]

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view

        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: EXTENSIONS for CollectionView delegates and datasource
extension PuzzleViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.piecesCollectionView ? piecesCVImages.count : boardCVImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PuzzleCollectionViewCell
        cell.layer.borderColor = UIColor.init(red: 243/255, green: 233/255, blue: 210/255, alpha: 1).cgColor
        cell.layer.borderWidth = 1
        cell.layer.backgroundColor = UIColor.white.cgColor

        if collectionView == piecesCollectionView {
            cell.setImage(image: piecesCVImages[indexPath.item])
        }
        if collectionView == boardCollectionView {
            if (boardCVImages[indexPath.item] as UIImage?) != nil {
                 cell.setImage(image: boardCVImages[indexPath.item])
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == piecesCollectionView {
            let width = (piecesCollectionView.frame.size.width - 30) / CGFloat(columns)
            return CGSize(width: width, height: width)
        } else {
            let width = (boardCollectionView.frame.size.width) / CGFloat(Double(boardCVImages.count).squareRoot())
            return CGSize(width: width, height: width)
            }
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == piecesCollectionView {
            return 5
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
             if collectionView == piecesCollectionView {
                return 5
            } else {
                return 0
            }
        }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    // display lookup image for 2 seconds
        if indexPath.item == (piecesCVImages.count - 1) {
            lookupImageView.isHidden = false
            lookupImageView.layer.borderColor = UIColor(red: 243/255, green: 233/255, blue: 210/255, alpha: 1).cgColor
            lookupImageView.layer.borderWidth = 5
            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.hideLookupImage), userInfo: nil, repeats: false)
        }
    }

    @objc func hideLookupImage() {
        lookupImageView.isHidden = true
    }
}

// MARK: EXTENSIONS for CollectionView drop and drag delegates
extension PuzzleViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIDropInteractionDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        if collectionView == boardCollectionView {
            return true
        } else {
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        selectedIndexPath = indexPath
        let image = piecesCVImages[indexPath.item]
        // Only allow the image to be moved it isn't a placeholder image
        if image != UIImage.init(named: "blank") && image != UIImage.init(named: "Gridy-lookup") {
        let itemProvider = NSItemProvider(object: image as UIImage)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = image
        return [dragItem]
        }
        return []
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith
        coordinator: UICollectionViewDropCoordinator) {
        if let indexPath = coordinator.destinationIndexPath {
            if indexPath.row >= correctOrderImages.count {
                return
            } else if collectionView == boardCollectionView {
                moveItems(coordinator: coordinator, destinationIndexPath: coordinator.destinationIndexPath!, collectionView: collectionView)
            }
            return
        }
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if destinationIndexPath!.row >= correctOrderImages.count {
            return UICollectionViewDropProposal(operation: .forbidden)
        } else if collectionView == boardCollectionView {
            return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
    }

    private func moveItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        totalMoves += 1
        let items = coordinator.items
        collectionView.performBatchUpdates({
            let dragItem = items.first!.dragItem.localObject as! UIImage
            //for correct move
            if dragItem == correctOrderImages[destinationIndexPath.item]{
                correctMoves += 1
                playSound(sound: "correctMove")
                consecutiveCorrectMoves += 1
                consecutiveIncorrectMoves = 0
                self.boardCVImages.insert(dragItem, at: destinationIndexPath.row)
                boardCollectionView.insertItems(at: [destinationIndexPath])
                piecesCVImages.remove(at: selectedIndexPath.row)
                piecesCVImages.insert(UIImage.init(named: "blank")!, at: selectedIndexPath.row)
                piecesCollectionView.reloadData()
            } else {
                //for incorrect move, image returns to piecesCollectionView
                playSound(sound: "incorrectMove")
                consecutiveIncorrectMoves += 1
                consecutiveCorrectMoves = 0
            }
        
        })
        collectionView.performBatchUpdates({
            let dragItem = items.first!.dragItem.localObject as! UIImage
            if dragItem == correctOrderImages[destinationIndexPath.item] {
                self.boardCVImages.remove(at: destinationIndexPath.row + 1)
                let nextIndexPath = IndexPath(row: destinationIndexPath.row + 1, section: 0)
                boardCollectionView.deleteItems(at: [nextIndexPath])

            }
        
        })
        coordinator.drop(items.first!.dragItem, toItemAt: destinationIndexPath)
        updateScore()
        if correctMoves == boardCVImages.count {
            playSound(sound: "victory")
            endGame()
        }
    }

    func playSound(sound: String) {
        if soundIsOn == true {
            let soundURL = Bundle.main.url(forResource: sound, withExtension: "mp3")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            } catch {
                print("Can't play sound")
            }
            audioPlayer.play()
        }
    }
}

