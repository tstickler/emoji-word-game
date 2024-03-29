//
//  User.swift
//  emojiWords
//
//  Created by Tyler Stickler on 4/4/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import UIKit

class User: NSObject {
    static let shared = User()
    let gemKey = "gem_count_key"
    let soundKey = "sound_effects_key"
    let completedLevelsKey = "completed_levels_key"
    let unlockedLevelPacksKey = "unlocked_packs_key"
    let helpKey = "help_key"
    let uniqueIdKey = "unique_id_key"
    let iapKey = "iap_key"

    let database = "dev"
    
    var gemCount: Int! {
        didSet {
            if let userId = userId {
                FirebaseManager.shared.writeGemCount(userId: userId,
                                                     gemCount: gemCount)
                GameData.shared.defaults.set(gemCount, forKey: gemKey)
            }
        }
    }
    var prefersSoundEffects: Bool!
    var completedLevels: [String: [Int]]! {
        didSet {
            for key in completedLevels.keys {
                completedLevels[key]?.sort()
            }

            if let userId = userId {
                FirebaseManager.shared.writeCompletedLevels(userId: userId,
                                                            levels: completedLevels)
            }
        }
    }
    var unlockedLevelPacks: [String]!
    var helpSeen: Bool!
    var userId: String?
    var inAppPurchases: [String]? {
        didSet {
            if let userId = userId {
                FirebaseManager.shared.writeInAppPurchases(userId: userId,
                                                           iaps: inAppPurchases)
                GameData.shared.defaults.set(inAppPurchases, forKey: iapKey)
            }
        }
    }

    private override init() {
        super.init()
        
        gemCount = GameData.shared.defaults.object(forKey: gemKey) as? Int ?? EnvironmentManager.shared.defaultGemCount
        prefersSoundEffects = GameData.shared.defaults.object(forKey: soundKey) as? Bool ?? true
        completedLevels = GameData.shared.defaults.dictionary(forKey: completedLevelsKey) as? [String: [Int]] ?? [String: [Int]]()
        unlockedLevelPacks = GameData.shared.defaults.array(forKey: unlockedLevelPacksKey) as? [String] ?? ["daily", "banana", "pineapple", "strawberry"]
        helpSeen = GameData.shared.defaults.object(forKey: helpKey) as? Bool ?? false
        userId = GameData.shared.defaults.object(forKey: uniqueIdKey) as? String
        inAppPurchases = GameData.shared.defaults.object(forKey: iapKey) as? [String] ?? [String]()
        signInAnon()
    }

    private func signInAnon() {
        FirebaseManager.shared.signInAnonymously { success, id in
            if let id = id, success {
                self.userId = id
                GameData.shared.defaults.set(id, forKey: self.uniqueIdKey)
                FirebaseManager.shared.writeDeviceName(userId: id,
                                                       deviceName: UIDevice.current.name)
            }
        }
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
        
        GameData.shared.defaults.set(identifier, forKey: uniqueIdKey)
        FirebaseManager.shared.writeDeviceName(userId: identifier,
                                               deviceName: UIDevice.current.name)
        return identifier
    }
}
