//
//  User.swift
//  emojiWords
//
//  Created by Tyler Stickler on 4/4/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//
import Foundation

class User: NSObject {
    static let shared = User()
    let gemKey = "gem_count_key"
    let soundKey = "sound_effects_key"
    let completedLevelsKey = "completed_levels_key"
    let unlockedLevelPacksKey = "unlocked_packs_key"
    let helpKey = "help_key"
    let uniqueIdKey = "unique_id_key"
    
    var gemCount: Int! {
        didSet {
            GameData.shared.ref.child("userGems").child(User.shared.userId!).setValue(User.shared.gemCount)
        }
    }
    var prefersSoundEffects: Bool!
    var completedLevels: [String: [Int]]!
    var unlockedLevelPacks: [String]!
    var helpSeen: Bool!
    var userId: String?

    private override init() {
        super.init()
        
        gemCount = GameData.shared.defaults.object(forKey: gemKey) as? Int ?? 100
        prefersSoundEffects = GameData.shared.defaults.object(forKey: soundKey) as? Bool ?? true
        completedLevels = GameData.shared.defaults.dictionary(forKey: completedLevelsKey) as? [String: [Int]] ?? [String: [Int]]()
        unlockedLevelPacks = GameData.shared.defaults.array(forKey: unlockedLevelPacksKey) as? [String] ?? ["banana", "pineapple", "strawberry"]
        helpSeen = GameData.shared.defaults.object(forKey: helpKey) as? Bool ?? false
        userId = GameData.shared.defaults.object(forKey: uniqueIdKey) as? String ?? createUniqueId()
    }
    
    private func createUniqueId() -> String {
        var identifier = "i-"
        
        for _ in 0..<12 {
            // Determine if letter or number should be added to the identifier
            let number = arc4random_uniform(2)
            
            // Case 0: append a number 0-9 to identifier
            // Case 1: append a letter A-Z to identifier
            if number == 0 {
                let num = arc4random_uniform(9) + 1
                identifier.append("\(num)")
            } else {
                let startingValue = Int(("A" as UnicodeScalar).value) // 65
                let c = Character(UnicodeScalar(Int(arc4random_uniform(26)) + startingValue)!)
                identifier.append(c)
            }
            
            // Add a - after every 4 characters in the identifier
            if identifier.count == 6 || identifier.count == 11  {
                identifier.append("-")
            }
        }
        
        GameData.shared.defaults.set(identifier, forKey: User.shared.uniqueIdKey)
        return identifier
    }
}
