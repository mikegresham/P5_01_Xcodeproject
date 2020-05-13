//
//  Creation.swift
//  Gridy
//
//  Created by Michael Gresham on 18/04/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class Creation {
    var image: UIImage
    static var defaultImage: UIImage {
        return UIImage.init(named:"lake")!
    }
    init() {
        image = Creation.defaultImage
    }
    func reset () {
        image = Creation.defaultImage
    }
    func collectRandomImageSet() -> [UIImage] {
        var randomImages = [UIImage]()
        let imageNames = ["lake", "paint", "lights", "railway", "road"]
        for i in 0 ..< imageNames.count {
                randomImages.append(UIImage.init(named: imageNames[i])!)
        }
        return randomImages
    }
}
