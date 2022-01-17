//
//  WordGame.swift
//  emojiWords
//
//  Created by Tyler Stickler on 3/24/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import Foundation

class WordGame {
    weak var delegate: WordGameDelegate?
    
    private var currentGuess = ""
    private var wheels = Array(repeating: [String](), count: 4)
    private var clues = [EmojiClue]()
    private var correctAnswers = [Int]()
    var sectorsPerWheel: Int!
    
    init(gameString: String) {
        /* Game initialization comes from a provided string giving all the details needed to construct the board
         The string will be structured as such:
         
         Sector count first
         Clue words second
         Wheel letters third
         
         Each portion of data will be separated by a delimiter
         % separates each section of data
         _ separates each data piece in the section
         6%nightswatch_cashcab_fortunecookie_tacobell_familytree_%okie_mily_cab_fa_hts_tr_eco_ta_pe_ll_ch_apil_cobe_for_ae_arp_looc_moa_ee_cash_tun_wat_nig_mp_
         
        */
        parseGameString(withString: gameString)
    }
    
    func startGame() {
        // Tell controller to set the UI elements according to the game
        setWheelLetters()
        setClues()
        clearGuess()
    }
    
    func addTextToAnswer(circleNumber: Int, sectorNumber: Int) {
        // Recieve text from the circle's and update guess accordingly
        let string = wheels[circleNumber][sectorNumber]
        setGuessText(withText: string)
    }
    
    func clearGuess() {
        // Emptry string clears guess
        setGuessText(withText: "")
    }
    
    func submitGuess() {
        // Anytime user submits a guess we want to clear the current guess
        // Hold our guess so we can clear it
        let guess = currentGuess
        clearGuess()
        
        for i in 0..<clues.count {
            // Guess was correct
            if clues[i].answer == guess {
                // Only indicate a correct guess if they haven't guessed it before
                if !correctAnswers.contains(i) {
                    correctGuess(at: i, guess: guess, shouldVibrate: true, revealedByHint: false)
                }
                
                return
            }
        }
        
        // Guess was more than 0 characters and was incorrect
        // Nothing happens if hitting guess button when there is no current guess
        if guess.count > 0 {
            // Communicate to controller an incorrect guess was made
            delegate?.incorrectGuess()
        }
    }
    
    func getClueInformation(clueIndex index: Int) {
        let clue = clues[index]
        delegate?.setClueInformation(emojis: clue.emojis, hint: clue.hint, words: clue.numOfWords, answer: clue.answer)
    }
    
    func fillSingleAnswer(correctSpot: Int) {
        correctGuess(at: correctSpot, guess: clues[correctSpot].answer, shouldVibrate: true, revealedByHint: true)
    }
    
    func fillCorrectAnswers(_ correctSpots: [Int]) {
        // Happens when user comes back to a game in progress
        for index in correctSpots {
            correctGuess(at: index, guess: clues[index].answer, shouldVibrate: false, revealedByHint: false)
        }
    }
    
    private func parseGameString(withString gameInitString: String) {
        // Split the string into an array of substrings separtated at the delimiter
        let splitGameString = gameInitString.split(separator: "%")
        let sectorCount = Int(String(splitGameString[0]))
        if let sectorCount = sectorCount {
            sectorsPerWheel = sectorCount
        }
        
        // These also have a delimiter to split at
        let words = splitGameString[1].split(separator: "_")
        let splitWords = splitGameString[2].split(separator: "_")
        
        // Grab clues according to the words
        let masterList = initializeMasterList()
        for word in words {
            let clue = getClueFromMaster(withWord: String(word), usingList: masterList)
            clues.append(clue)
        }
        
        // Set the labels on the wheels
        for word in splitWords {
            buildWheelArray(withWord: String(word))
        }
    }
    
    private func getClueFromMaster(withWord word: String, usingList list: Array<Dictionary<String ,String>>) -> EmojiClue {
        var clue: EmojiClue!
        
        for item in list {
            if item["Phrase"] == word {
                if let emojiClue = item["Clue"], let answer = item["Phrase"], let numOfWords = item["Num of words"], let hint = item["Hint"] {
                    clue = EmojiClue(emojis: emojiClue, answer: answer, numOfWords: Int(numOfWords)!, hint: hint)
                }
            }
        }

        return clue
    }
    
    private func initializeMasterList() -> Array<Dictionary<String, String>> {
        if let path = Bundle.main.path(forResource: "master", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let master = jsonResult as? Array<Dictionary<String, String>> {
                    // do stuff
                    return master
                }
            } catch {
                // handle error
            }
        }
        
        return []
    }
    
    private func buildWheelArray(withWord word: String) {
        // Loop through the wheels and assign thier letters
        // There are 4 total wheels
        // Index 0 is top right
        // Index 1 is top left
        // Index 2 is bottom right
        // Index 3 is bottom left
        for i in 0..<wheels.count {
            if wheels[i].count < sectorsPerWheel {
                wheels[i].append(word)
                return
            }
        }
        
    }
        
    private func setWheelLetters() {
        // Communicate to controller what should be on the wheels
        delegate?.setWheelLetter(wheels: self.wheels)
    }
    
    private func setClues() {
        // Communicate to controller what clues should display
        delegate?.setClues(clues: self.clues)
    }
    
    private func setGuessText(withText text: String) {
        if text == "" {
            // Recieving an empty string means to reset the guess
            currentGuess = ""
        } else {
            // Any string other than empty, build the guess
            currentGuess += text
        }
        
        // Communicate to controller that the guess has updated
        delegate?.updateGuessText(withText: currentGuess)
    }
    
    private func correctGuess(at correctSpot: Int, guess: String, shouldVibrate: Bool, revealedByHint: Bool) {
        correctAnswers.append(correctSpot)
        
        // Communicate to controller a correct guess was made
        delegate?.revealWord(at: correctSpot, word: guess, shouldVibrate: shouldVibrate, revealedByHint: revealedByHint)
    }
    
    func isGameOver() {
        if correctAnswers.count == 5 {
            gameOver()
        } else if correctAnswers.count == 3 {
            delegate?.shouldShowAd()
        }
    }
    
    private func gameOver() {
        delegate?.gameOver()
    }
}
