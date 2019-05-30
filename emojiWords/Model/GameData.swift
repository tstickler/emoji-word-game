//
//  GameData.swift
//  emojiWords
//
//  Created by Tyler Stickler on 4/20/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import FirebaseDatabase

class GameData {
    static let shared = GameData()
    
    // Each key maps to another dictionary where the key is the name of the level pack
    // and the array of strings is an array containing each level string for that pack.
    var levels: Dictionary<String, [String]>?
    var defaults = UserDefaults.standard
    var ref: DatabaseReference!
    
    private init() {
        levels = readInLevels()
        ref = Database.database().reference()
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
