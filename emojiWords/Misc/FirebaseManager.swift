//
//  FirebaseManager.swift
//  emojiWords
//
//  Created by Tyler Stickler on 1/17/22.
//  Copyright © 2022 Tyler Stickler. All rights reserved.
//

import Firebase
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    private var ref: DatabaseReference!
    private var environment = EnvironmentManager.shared.environment

    init() {
        ref = Database.database().reference()
    }

    func signInAnonymously(completion: @escaping (Bool, String?) -> Void) {
        Auth.auth().signInAnonymously { authResult, error in
            guard let authResult = authResult else {
                completion(false, nil)
                return
            }
            completion(true, authResult.user.uid)
        }
    }

    func writeDeviceName(userId: String, deviceName: String) {
        ref.child(environment.rawValue)
            .child("users")
            .child(userId)
            .child("device_name")
            .setValue(deviceName)
    }

    func writeCompletedLevels(userId: String, levels: [String: [Int]]) {
        ref.child(environment.rawValue)
            .child("users")
            .child(userId)
            .child("completed_levels")
            .setValue(levels)
    }

    func writeGemCount(userId: String, gemCount: Int) {
        ref.child(environment.rawValue)
            .child("users")
            .child(userId)
            .child("gems")
            .setValue(gemCount)
    }

    func writeInAppPurchases(userId: String, iaps: [String]?) {
        ref.child(environment.rawValue)
            .child("users")
            .child(userId)
            .child("in_app_purchases")
            .setValue(iaps)
    }
}
