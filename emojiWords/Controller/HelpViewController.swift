//
//  HelpViewController.swift
//  emojiWords
//
//  Created by Tyler Stickler on 5/27/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    @IBOutlet weak var unrevealedPopUp: PopUpInformationView!
    @IBOutlet weak var revealedPopUp: PopUpInformationView!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var emojiClue: UIView!
    @IBOutlet weak var helpCircle: SegmentedCircleView!
    @IBOutlet weak var guessView: UIView!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    
    @IBAction func returnButtonTapped(_ sender: Any) {
        if let id = User.shared.userId {
            FirebaseManager.shared.writeViewedHelp(userId: id, viewed: true)
        }
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emojiClue.layer.borderColor = UIColor.black.cgColor
        emojiClue.layer.borderWidth = 2
        
        guessView.layer.borderColor = UIColor.black.cgColor
        guessView.layer.borderWidth = 2

        guessButton.layer.borderColor = UIColor.black.cgColor
        guessButton.layer.borderWidth = 2
        
        returnButton.layer.borderColor = UIColor.black.cgColor
        returnButton.layer.borderWidth = 2

        arrow.transform = CGAffineTransform(rotationAngle: .pi / 2)
        unrevealedPopUp.emojisText = "👨‍👩‍👧‍👦🌳"
        
        revealedPopUp.hintIsRevealed = true
        revealedPopUp.emojisText = "👨‍👩‍👧‍👦🌳"
        revealedPopUp.hintText = "Diagram of your relatives"
        revealedPopUp.wordsCount = 2
        revealedPopUp.letterCount = 10
        
        helpCircle.numOfSegments = 6
        helpCircle.setCircleColor(withColor: UIColor.init(red: 255/255,
                                                          green: 39/255,
                                                          blue: 35/255,
                                                          alpha: 1.0).cgColor)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let wheelLetters = ["fam", "no", "il", "uhuh","yt", "ree"]
        var skippedOffset = 0
        for j in 0..<helpCircle.labels.count {
            if helpCircle.labels[j].isHidden {
                skippedOffset += 1
                continue
            } else {
                helpCircle.labels[j].alpha = 1.0
                helpCircle.labels[j].text = wheelLetters[j - skippedOffset].uppercased()
            }
        }
    }
}
