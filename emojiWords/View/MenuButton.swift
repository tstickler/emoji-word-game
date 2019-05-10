//
//  MenuButton.swift
//  emojiWords
//
//  Created by Tyler Stickler on 4/30/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import UIKit

class HighlightedButton: UIButton {
    // Nice highlight effect when menu button is tapped
    override open var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? .black : .clear
            alpha = isHighlighted ? 0.2 : 1
        }
    }
}
