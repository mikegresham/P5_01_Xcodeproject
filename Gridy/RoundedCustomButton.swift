//
//  RoundedCustomButton.swift
//  Gridy
//
//  Created by Michael Gresham on 18/04/2020.
//  Copyright © 2020 Michael Gresham. All rights reserved.
//

import Foundation
import UIKit

class RoundedCustomButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = CGFloat(10)
    }
}
