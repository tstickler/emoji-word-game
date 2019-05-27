//
//  HintPopUpDelegate.swift
//  emojiWords
//
//  Created by Tyler Stickler on 5/5/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

protocol HintPopUpDelegate: class {
    func revealHintTapped()
    func revealWordTapped(atSpot spot: Int)
    func closePopUp()
}

