//
//  EnvironmentManager.swift
//  emojiWords
//
//  Created by Tyler Stickler on 1/17/22.
//  Copyright © 2022 Tyler Stickler. All rights reserved.
//

import Foundation

enum Environment: String {
    case dev
    case prod
}

class EnvironmentManager {
    static var shared = EnvironmentManager()

    let environment: Environment = .dev

    var defaultGemCount: Int
    var interstitialAdUnitId: String
    var rewardAdUnitId: String

    init() {
        switch environment {
        case .dev:
            defaultGemCount = 1000
            interstitialAdUnitId = "ca-app-pub-3940256099942544/5135589807"
            rewardAdUnitId = "ca-app-pub-3940256099942544/1712485313"
        case .prod:
            defaultGemCount = 100
            interstitialAdUnitId = "ca-app-pub-8582279935838668/8878947049"
            rewardAdUnitId = "ca-app-pub-8582279935838668/5330390753"
        }
    }
}
