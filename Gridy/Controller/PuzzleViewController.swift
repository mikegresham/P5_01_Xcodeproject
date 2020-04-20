//
//  PuzzleViewController.swift
//  Gridy
//
//  Created by Michael Gresham on 18/04/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class PuzzleViewController: UIViewController {
    
    var creation = Creation.init()
    var piecesCVImages = [UIImage]()
    var correctOrderImages = [UIImage]()
    var boardCVImages = [UIImage]()
    var columns = Int()
    
    @IBOutlet weak var piecesCollectionView: UICollectionView!
    @IBOutlet weak var boardCollectionView: UICollectionView!
    @IBOutlet weak var piecesCollectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var boardCollectionViewFlowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        piecesCollectionView.dataSource = self
        piecesCollectionView.delegate = self
        boardCollectionView.dataSource = self
        boardCollectionView.delegate = self

        super.viewDidLoad()
        
        correctOrderImages = piecesCVImages
        piecesCVImages = piecesCVImages.shuffled()
        print(piecesCVImages.count)
        
        piecesCollectionView.reloadData()
        boardCollectionView.reloadData()
        if piecesCVImages.count == 25 {
            columns = 7
        } else if piecesCVImages.count == 16 {
            columns = 6
        } else {
            columns = 5
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}

extension PuzzleViewController: UICollectionViewDelegate {
    
}

extension PuzzleViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.piecesCollectionView ? piecesCVImages.count : piecesCVImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PuzzleCollectionViewCell
        cell.layer.borderColor = UIColor.init(red: 243/255, green: 233/255, blue: 210/255, alpha: 1).cgColor
        cell.layer.borderWidth = 1
        cell.layer.backgroundColor = UIColor.white.cgColor
        
        if collectionView == piecesCollectionView {
            cell.setImage(image: piecesCVImages[indexPath.item])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionView == piecesCollectionView {
            let width = (piecesCollectionView.frame.size.width - 30) / CGFloat(columns)
            return CGSize(width: width, height: width)
        } else {
            let width = (boardCollectionView.frame.size.width) / CGFloat(Double(piecesCVImages.count).squareRoot())
            return CGSize(width: width, height: width)
            }
        }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            
        if collectionView == piecesCollectionView {
            return 5
        } else {
            return -5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
             if collectionView == piecesCollectionView {
                return 5
            } else {
                return -5
            }
        }
}

