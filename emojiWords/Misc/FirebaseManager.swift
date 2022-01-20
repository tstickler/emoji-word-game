//
//  FirebaseManager.swift
//  emojiWords
//
//  Created by Tyler Stickler on 1/17/22.
//  Copyright © 2022 Tyler Stickler. All rights reserved.
//

import Firebase
import FirebaseAuth
import Foundation

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

    func writeLastActive(userId: String, action: String, date: Date = Date()) {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC") ?? formatter.timeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let now = formatter.string(from: date)

        ref.child(environment.rawValue)
            .child("users")
            .child(userId)
            .child("last_active")
            .setValue(["time": now, "action": action])
    }

    func writeDeviceName(userId: String, deviceName: String) {
        ref.child(environment.rawValue)
            .child("users")
            .child(userId)
            .child("device_name")
            .setValue(deviceName)
        writeLastActive(userId: userId, action: #function)
    }

    func writeCompletedLevels(userId: String, levels: [String: [Int]]) {
        ref.child(environment.rawValue)
            .child("users")
            .child(userId)
            .child("completed_levels")
            .setValue(levels)
        writeLastActive(userId: userId, action: #function)
    }

    func writeGemCount(userId: String, gemCount: Int) {
        ref.child(environment.rawValue)
            .child("users")
            .child(userId)
            .child("gems")
            .setValue(gemCount)
        writeLastActive(userId: userId, action: #function)
    }

    func writeInAppPurchases(userId: String, iaps: [String]?) {
        ref.child(environment.rawValue)
            .child("users")
            .child(userId)
            .child("in_app_purchases")
            .setValue(iaps)
        writeLastActive(userId: userId, action: #function)
    }

    func writeViewedHelp(userId: String, viewed: Bool) {
        ref.child(environment.rawValue)
            .child("users")
            .child(userId)
            .child("viewed_help")
            .setValue(viewed)
        writeLastActive(userId: userId, action: #function)
    }
}
