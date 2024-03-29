//
//  GameData.swift
//  emojiWords
//
//  Created by Tyler Stickler on 4/20/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import Foundation

class GameData {
    static let shared = GameData()

    // Gem rewards
    let wordGemReward = 1
    let levelGemReward = 5
    let packGemReward = 200

    let dailyBonus = 2

    // Gem purchases
    let hintGemPurchase = 10
    let wordGemPurchase = 20
    let packGemPurchase = 500
    
    // Each key maps to another dictionary where the key is the name of the level pack
    // and the array of strings is an array containing each level string for that pack.
    var levels: Dictionary<String, [String]>?
    var defaults = UserDefaults.standard
    
    private init() {
        levels = readInLevels()
    }
    
    private func readInLevels() -> [String: [String]] {
        if let path = Bundle.main.path(forResource: "levels", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let master = jsonResult as? Dictionary<String,[String]> {
                    // do stuff
                    return master
                }
            } catch {
                // handle error
            }
        }
        
        return [:]
    }
}
