//
//  PopUpInformationView.swift
//  emojiWords
//
//  Created by Tyler Stickler on 3/29/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import UIKit

class PopUpInformationView: UIView {
    private var frameWidth: CGFloat!
    private var frameHeight: CGFloat!
    weak var delegate: HintPopUpDelegate?
    var blurView: UIVisualEffectView!
    private var revealButton = UIButton(type: .system)
    private var adButton = UIButton(type: .system)
    var emojisText: String = ""
    var hintText: String = ""
    var wordsCount: Int = 0
    var letterCount: Int = 0
    var hintIsRevealed = false
    var wordIsRevealed = false
    var infoForClue = 0
    private var shapeIsDrawn = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if shapeIsDrawn {
            return
        }
        
        frameHeight = 220//self.superview!.frame.height * 0.2
        frameWidth = 250//self.superview!.frame.width * 0.6
        
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: frameWidth, height: frameHeight)
        
        drawBox()
        addLabels()
        shapeIsDrawn = true
    }
    
    private func drawBox() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: frameHeight))
        path.addLine(to: CGPoint(x: frameWidth, y: frameHeight))
        path.addLine(to: CGPoint(x: frameWidth, y: 10))
        path.addLine(to: CGPoint(x: 10, y: 10))
        path.close()
        
        let box = CAShapeLayer()
        box.path = path.cgPath
        box.anchorPoint = .zero
        box.strokeColor = UIColor.black.cgColor
        box.fillColor = UIColor.white.cgColor
        box.position = CGPoint(x: 0, y: 0)
        box.zPosition = 0.98
        box.lineWidth = 2.0
        self.layer.addSublayer(box)
        
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = CGSize(width: -0.1, height: 4)
        self.layer.shadowRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func addLabels() {
        let emojiLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        emojiLabel.font = UIFont(name: "EmojiOne", size: 48)
        emojiLabel.text = emojisText
        emojiLabel.textAlignment = .center
        emojiLabel.layer.zPosition = 0.99
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let hintLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        hintLabel.font = UIFont(name: "VTC-GarageSale", size: 22)
        hintLabel.text = hintText
        hintLabel.numberOfLines = 3
        hintLabel.minimumScaleFactor = 0.5
        hintLabel.adjustsFontSizeToFitWidth = true
        hintLabel.textAlignment = .center
        hintLabel.layer.zPosition = 0.99
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let wordsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        wordsLabel.font = UIFont(name: "VTC-GarageSale", size: 17)
        wordsLabel.text = "Words: \(wordsCount)"
        wordsLabel.numberOfLines = 1
        wordsLabel.textAlignment = .left
        wordsLabel.layer.zPosition = 0.99
        wordsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let lettersLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        lettersLabel.font = UIFont(name: "VTC-GarageSale", size: 17)
        lettersLabel.text = "Letters: \(letterCount)"
        lettersLabel.numberOfLines = 1
        lettersLabel.textAlignment = .right
        lettersLabel.layer.zPosition = 0.99
        lettersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let blur = UIBlurEffect(style: .light)
        blurView = UIVisualEffectView(effect: blur)
        blurView.layer.borderWidth = 2
        blurView.layer.borderColor = UIColor.black.cgColor
        blurView.alpha = 1.0
        blurView.frame = self.bounds
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.zPosition = 1.0
        
        let revealLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        revealLabel.font = UIFont(name: "VTC-GarageSale", size: 30)
        revealLabel.text = "REVEAL HINT?"
        revealLabel.numberOfLines = 1
        revealLabel.textAlignment = .center
        revealLabel.layer.zPosition = 1.0
        revealLabel.translatesAutoresizingMaskIntoConstraints = false

        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.spacing = 6

        revealButton.frame = CGRect(x: 0, y: 0, width: 90, height: 40)
        if User.shared.gemCount < 10 {
            revealButton.backgroundColor = UIColor.init(red: 255/255,
                                                        green: 39/255,
                                                        blue: 35/255,
                                                        alpha: 1.0)
        } else {
            revealButton.backgroundColor = .white
        }
        revealButton.setTitle("\(GameData.shared.hintGemPurchase) GEMS", for: .normal)
        revealButton.titleLabel?.font = UIFont(name: "VTC-GarageSale", size: 22)
        revealButton.setTitleColor(.black, for: .normal)
        revealButton.layer.borderColor = UIColor.black.cgColor
        revealButton.layer.borderWidth = 2.0
        revealButton.translatesAutoresizingMaskIntoConstraints = false
        revealButton.addTarget(self, action: #selector(revealButtonTapped), for: .touchUpInside)

        adButton.frame = CGRect(x: 0, y: 0, width: 90, height: 40)
        adButton.setTitle("Watch Ad", for: .normal)
        adButton.titleLabel?.font = UIFont(name: "VTC-GarageSale", size: 22)
        adButton.setTitleColor(.black, for: .normal)
        adButton.backgroundColor = .white
        adButton.layer.borderColor = UIColor.black.cgColor
        adButton.layer.borderWidth = 2.0
        adButton.translatesAutoresizingMaskIntoConstraints = false
        adButton.addTarget(self, action: #selector(watchAdTapped), for: .touchUpInside)

        buttonStack.addArrangedSubview(revealButton)
        buttonStack.addArrangedSubview(adButton)
        
        let closeButton = UIButton(type: .system)
        closeButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        closeButton.backgroundColor = .clear
        closeButton.setTitle("X", for: .normal)
        closeButton.layer.zPosition = 1.0
        closeButton.titleLabel?.font = UIFont(name: "VTC-GarageSale", size: 20)
        closeButton.setTitleColor(UIColor.init(red: 255/255,
                                               green: 39/255,
                                               blue: 35/255,
                                               alpha: 1.0), for: .normal)
        closeButton.addTarget(self, action: #selector(closeFrame), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let revealWordButton = UIButton(type: .system)
        revealWordButton.setTitle("REVEAL WORD - \(GameData.shared.wordGemPurchase) GEMS", for: .normal)
        revealWordButton.layer.zPosition = 0.99
        revealWordButton.titleLabel?.font = UIFont(name: "VTC-GarageSale", size: 22)
        revealWordButton.setTitleColor(.black, for: .normal)
        if (User.shared.gemCount < 30 && !hintIsRevealed) || (User.shared.gemCount < 20 && hintIsRevealed) {
            revealWordButton.backgroundColor = UIColor.init(red: 255/255,
                                                        green: 39/255,
                                                        blue: 35/255,
                                                        alpha: 1.0)
        } else {
            revealWordButton.backgroundColor = .white
        }
        revealWordButton.layer.borderColor = UIColor.black.cgColor
        revealWordButton.layer.borderWidth = 2.0
        revealWordButton.translatesAutoresizingMaskIntoConstraints = false
        revealWordButton.addTarget(self, action: #selector(revealWordTapped), for: .touchUpInside)
        var revealWordButtonHeightConstant: CGFloat = 30.0
        if wordIsRevealed {
            revealWordButtonHeightConstant = 0.0
            revealWordButton.isHidden = true
        }
        
        addSubview(emojiLabel)
        addSubview(hintLabel)
        addSubview(wordsLabel)
        addSubview(lettersLabel)
        addSubview(blurView)
        //blurView.contentView.addSubview(revealButton)
        blurView.contentView.addSubview(revealLabel)
        addSubview(closeButton)
        addSubview(revealWordButton)
        blurView.contentView.addSubview(buttonStack)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: emojiLabel,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 16))
        constraints.append(NSLayoutConstraint(item: emojiLabel,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: emojiLabel,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: frameWidth))
        constraints.append(NSLayoutConstraint(item: emojiLabel,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 70))
        
        constraints.append(NSLayoutConstraint(item: hintLabel,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: hintLabel,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: emojiLabel,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -16))
        constraints.append(NSLayoutConstraint(item: hintLabel,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: wordsLabel,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: hintLabel,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: frameWidth - 10))
        
        constraints.append(NSLayoutConstraint(item: wordsLabel,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: revealWordButton,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: -6))
        constraints.append(NSLayoutConstraint(item: wordsLabel,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 6))
        constraints.append(NSLayoutConstraint(item: wordsLabel,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: frameWidth/2))
        
        constraints.append(NSLayoutConstraint(item: lettersLabel,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: revealWordButton,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: -6))
        constraints.append(NSLayoutConstraint(item: lettersLabel,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: -6))
        constraints.append(NSLayoutConstraint(item: lettersLabel,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: frameWidth/2))
        
        constraints.append(NSLayoutConstraint(item: blurView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: emojiLabel,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -5))
        constraints.append(NSLayoutConstraint(item: blurView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: -1))
        constraints.append(NSLayoutConstraint(item: blurView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 1))
        constraints.append(NSLayoutConstraint(item: blurView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 1))
        
        constraints.append(NSLayoutConstraint(item: revealLabel,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: blurView,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: revealLabel,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: revealButton,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: revealLabel,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: 150))
        
        constraints.append(NSLayoutConstraint(item: buttonStack,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: blurView,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: buttonStack,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: blurView,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0))

        constraints.append(NSLayoutConstraint(item: revealButton,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: 100))
        constraints.append(NSLayoutConstraint(item: revealButton,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 40))

        constraints.append(NSLayoutConstraint(item: adButton,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: 100))
        constraints.append(NSLayoutConstraint(item: adButton,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 40))

        constraints.append(NSLayoutConstraint(item: closeButton,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 12))
        constraints.append(NSLayoutConstraint(item: closeButton,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: -1))
        
        constraints.append(NSLayoutConstraint(item: revealWordButton,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -6))
        constraints.append(NSLayoutConstraint(item: revealWordButton,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 6))
        constraints.append(NSLayoutConstraint(item: revealWordButton,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: revealWordButton,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: revealWordButtonHeightConstant))
        
        NSLayoutConstraint.activate(constraints)
        
        if hintIsRevealed {
            blurView.alpha = 0
            revealButton.alpha = 0
        }
    }
    
    @objc func closeFrame() {
        delegate?.closePopUp()
    }
    
    @objc func revealButtonTapped() {
        delegate?.revealHintTapped()
    }

    @objc func watchAdTapped() {
        delegate?.playAdTapped()
    }
    
    @objc func revealWordTapped(atSpace: Int) {
        if hintIsRevealed {
            delegate?.revealWordTapped(atSpot: infoForClue)
        }
    }
}
