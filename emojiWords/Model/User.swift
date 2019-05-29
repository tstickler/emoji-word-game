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
    
    var gemCount: Int!
    var prefersSoundEffects: Bool!
    var completedLevels: [String: [Int]]!
    var unlockedLevelPacks: [String]!
    var helpSeen: Bool!
    var userId: String?

    private override init() {
        gemCount = GameData.shared.defaults.object(forKey: gemKey) as? Int ?? 100
        prefersSoundEffects = GameData.shared.defaults.object(forKey: soundKey) as? Bool ?? true
        completedLevels = GameData.shared.defaults.dictionary(forKey: completedLevelsKey) as? [String: [Int]] ?? [String: [Int]]()
        unlockedLevelPacks = GameData.shared.defaults.array(forKey: unlockedLevelPacksKey) as? [String] ?? ["banana", "pineapple", "strawberry"]
        helpSeen = GameData.shared.defaults.object(forKey: helpKey) as? Bool ?? false
        userId = GameData.shared.defaults.string(forKey: uniqueIdKey)
    }
}
