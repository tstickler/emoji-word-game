//
//  LevelPopUpDelegate.swift
//  emojiWords
//
//  Created by Tyler Stickler on 5/8/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

protocol LevelPopUpDelegate: class {
    func handleLevelButton(level: Int)
    func handleIapButton()
    func handleGemsButton()
    func handleRestorePurchase()
}

