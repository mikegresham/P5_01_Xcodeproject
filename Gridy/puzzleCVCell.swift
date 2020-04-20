//
//  puzzleCVCell.swift
//  Gridy
//
//  Created by Michael Gresham on 20/04/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class PuzzleCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    func setImage(image: UIImage?) {
        imageView.image = image
    }

}
