//
//  InAppPurchaseDelegate.swift
//  emojiWords
//
//  Created by Tyler Stickler on 5/8/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

protocol InAppPurchaseDelegate: class {
    func levelPackPurchaseCompleted()
    func redeemGemPurchase(gemCount: Int)
}
