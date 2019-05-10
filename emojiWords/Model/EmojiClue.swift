//
//  EmojiClue.swift
//  emojiWords
//
//  Created by Tyler Stickler on 3/24/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

class EmojiClue {
    var emojis: String!
    var answer: String!
    var numOfWords: Int!
    var hint: String!
    
    init(emojis: String, answer: String, numOfWords: Int, hint: String) {
        self.emojis = emojis
        self.answer = answer
        self.numOfWords = numOfWords
        self.hint = hint
    }
}
