//
//  WordGameDelegate.swift
//  emojiWords
//
//  Created by Tyler Stickler on 3/24/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

protocol WordGameDelegate: class {
    func updateGuessText(withText text: String)
    func setWheelLetter(wheels: [[String]])
    func setClues(clues: [EmojiClue])
    func revealWord(at correctSpot: Int, word: String, shouldVibrate: Bool, revealedByHint: Bool)
    func incorrectGuess()
    func setClueInformation(emojis: String, hint: String, words: Int, answer: String)
    func gameOver()
    func shouldShowAd()
}
