//
//  MenuDelegate.swift
//  emojiWords
//
//  Created by Tyler Stickler on 4/29/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

protocol MenuDelegate: class {
    func homeButtonInteraction()
    func levelsButtonInteraction()
    func soundInteraction()
    func helpInteraction()
    func iapPurchaseTapped(ofCount: Int)
    func removeAdsTapped()
}
