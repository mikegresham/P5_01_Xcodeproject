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
}
