//
//  MenuView.swift
//  emojiWords
//
//  Created by Tyler Stickler on 4/26/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import UIKit

class MenuView: UIView {
    weak var delegate: MenuDelegate?
    private var soundLabel: UILabel?
    private var iapButtonStacks = [UIStackView]()
    private var iapButtons = [HighlightedButton]()
    private var shapeIsDrawn = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        if shapeIsDrawn {
            return
        }
        
        self.backgroundColor = .white
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 3.5
        self.layer.zPosition = 1.0
        
        addMenuButtons()
        shapeIsDrawn = true
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addMenuButtons() {
        let topStack = UIStackView()
        topStack.axis = .vertical
        topStack.spacing = 3
        topStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topStack)
        
        let homeStack = createMenuButton(buttonTitle: "HOME", image: "house")
        let levelsStack = createMenuButton(buttonTitle: "LEVELS", image: "invader")
        let gemsStack = createMenuButton(buttonTitle: "BUY GEMS", image: "gem")
        let removeAds = createMenuButton(buttonTitle: "REMOVE ADS", image: "cross-mark")
        topStack.addArrangedSubview(homeStack)
        topStack.addArrangedSubview(levelsStack)
        topStack.addArrangedSubview(removeAds)
        topStack.addArrangedSubview(gemsStack)

        let oneHundred = createIAPButton(ofCount: 100, forPrice: 1)
        let twoFifty = createIAPButton(ofCount: 250, forPrice: 2)
        let sevenFifty = createIAPButton(ofCount: 750, forPrice: 5)
        let twoThousand = createIAPButton(ofCount: 2000, forPrice: 10)
        let fiveThousand = createIAPButton(ofCount: 5000, forPrice: 20)

        topStack.addArrangedSubview(oneHundred)
        topStack.addArrangedSubview(twoFifty)
        topStack.addArrangedSubview(sevenFifty)
        topStack.addArrangedSubview(twoThousand)
        topStack.addArrangedSubview(fiveThousand)
        
        iapButtonStacks.append(oneHundred)
        iapButtonStacks.append(twoFifty)
        iapButtonStacks.append(sevenFifty)
        iapButtonStacks.append(twoThousand)
        iapButtonStacks.append(fiveThousand)
        
        let bottomStack = UIStackView()
        bottomStack.axis = .vertical
        bottomStack.spacing = 6
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomStack)

        let helpStack = createMenuButton(buttonTitle: "HELP", image: "question")
        let soundStack = createMenuButton(buttonTitle: "SOUND: OFF", image: "speaker")
        for subview in soundStack.arrangedSubviews {
            if let subview = subview as? UILabel {
                soundLabel = subview
                updateSoundLabel()
            }
        }
        bottomStack.addArrangedSubview(soundStack)
        bottomStack.addArrangedSubview(helpStack)
        
        let bottomStackLine = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 2))
        bottomStackLine.backgroundColor = .groupTableViewBackground
        bottomStackLine.layer.zPosition = 1.0
        bottomStackLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomStackLine)

        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item: topStack,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: (UIApplication.shared.keyWindow?.safeAreaInsets.top)! + 40))
        constraints.append(NSLayoutConstraint(item: topStack,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 20))
        
        constraints.append(NSLayoutConstraint(item: bottomStack,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -(UIApplication.shared.keyWindow?.safeAreaInsets.bottom)! - 40))
        constraints.append(NSLayoutConstraint(item: bottomStack,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 20))
        constraints.append(NSLayoutConstraint(item: bottomStackLine,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: bottomStackLine,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: bottomStackLine,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: bottomStack,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: bottomStackLine,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 1))
        
        
        NSLayoutConstraint.activate(constraints)
    }

    func createMenuButton(buttonTitle: String, image: String) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonImage = UIImageView(image: UIImage(named: image))
        buttonImage.contentMode = .scaleAspectFit
        buttonImage.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        let buttonLabel = UILabel()
        buttonLabel.text = buttonTitle
        buttonLabel.font = UIFont(name: "VTC-GarageSale", size: 36)
        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(buttonImage)
        stack.addArrangedSubview(buttonLabel)
        addSubview(stack)
        
        let button = HighlightedButton()
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(image, for: .normal)
        button.setTitleColor(.clear, for: .normal)
        button.addTarget(self, action: #selector(menuButtonTapped(sender:)), for: .touchUpInside)
        addSubview(button)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: buttonImage,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: 30))
        constraints.append(NSLayoutConstraint(item: stack,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: self.frame.height / 15))
        
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: stack,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: stack,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0))
        NSLayoutConstraint.activate(constraints)
        
        return stack
    }
    
    func createIAPButton(ofCount count: Int, forPrice price: Int) -> UIStackView {
        let stack = UIStackView()
        stack.alpha = 0
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let discount = Int(100 * (count - 100 * price) / (100*price))
        let discountTop = UILabel()
        discountTop.text = "\(discount)%"
        discountTop.font = UIFont(name: "VTC-GarageSale", size: 18)
        discountTop.textColor = UIColor.init(red: 255/255,
                                          green: 39/255,
                                          blue: 35/255,
                                          alpha: 1.0)
        discountTop.translatesAutoresizingMaskIntoConstraints = false
        discountTop.textAlignment = .center
        
        let discountBottom = UILabel()
        discountBottom.text = "EXTRA"
        discountBottom.font = UIFont(name: "VTC-GarageSale", size: 18)
        discountBottom.textColor = UIColor.init(red: 255/255,
                                          green: 39/255,
                                          blue: 35/255,
                                          alpha: 1.0)
        discountBottom.translatesAutoresizingMaskIntoConstraints = false
        discountBottom.textAlignment = .center
        
        let discountStack = UIStackView()
        discountStack.axis = .vertical
        discountStack.spacing = 0
        discountStack.distribution = .fill
        discountStack.translatesAutoresizingMaskIntoConstraints = false
        discountStack.addArrangedSubview(discountTop)
        discountStack.addArrangedSubview(discountBottom)
        if discount == 0 {
            discountStack.alpha = 0
        }
        
        let buttonLabel = UILabel()
        buttonLabel.text = "\(count) GEMS"
        buttonLabel.font = UIFont(name: "VTC-GarageSale", size: 28)
        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonLabel.textAlignment = .right
        
        stack.addArrangedSubview(buttonLabel)
        stack.addArrangedSubview(discountStack)
        addSubview(stack)
        
        let button = HighlightedButton()
        button.setTitle("iap", for: .normal)
        button.tag = count
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        button.setTitleColor(.clear, for: .normal)
        button.addTarget(self, action: #selector(menuButtonTapped(sender:)), for: .touchUpInside)
        iapButtons.append(button)
        addSubview(button)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: stack,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 33))
        
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: stack,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: stack,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: button,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0))
        NSLayoutConstraint.activate(constraints)
        
        return stack
    }
    
    func updateSoundLabel() {
        guard let soundLabel = soundLabel else {
            return
        }
        
        var soundString = ""
        if User.shared.prefersSoundEffects {
            soundString = "SOUND: ON"
        } else {
            soundString = "SOUND: OFF"
        }
        
        // Highlight the status of the sound with either green or red color
        let attributedString = NSMutableAttributedString(string: soundString)
        attributedString.setColorForText(textForAttribute: "ON", withColor: UIColor.init(red: 3/255,
                                                                                         green: 192/255,
                                                                                         blue: 60/255,
                                                                                         alpha: 1.0))
        attributedString.setColorForText(textForAttribute: "OFF", withColor: UIColor.init(red: 255/255,
                                                                                          green: 39/255,
                                                                                          blue: 35/255,
                                                                                          alpha: 1.0))
        soundLabel.attributedText = attributedString
    }

    @objc func menuButtonTapped(sender: HighlightedButton) {
        // Button title is set to whatever the underlying image name is
        let buttonSeletion = sender.title(for: .normal)
        
        switch buttonSeletion {
        case "house":
            // Unwind segue to home screen
            delegate?.homeButtonInteraction()
        case "invader":
            // Return to level selection screen
            delegate?.levelsButtonInteraction()
        case "gem":
            // Show in app purchases
            if !isAnimating {
                if iapButtonStacks[0].alpha == 0 {
                    animateIapButtons(withIndex: 0, toAlpha: 1.0, stopIndex: iapButtonStacks.count)
                } else {
                    animateIapButtons(withIndex: iapButtonStacks.count - 1, toAlpha: 0.0, stopIndex: -1)
                }
            }
        case "speaker":
            // Modify sound preference
            delegate?.soundInteraction()
        case "question":
            // Display help
            delegate?.helpInteraction()
        case "iap":
            // User is attempting to purchase an item
            // Button tag is holding the amount trying to be purchased
            delegate?.iapPurchaseTapped(ofCount: sender.tag)
        case "cross-mark":
            delegate?.removeAdsTapped()
        default:
            return
        }
    }
    
    private var isAnimating = false
    private func animateIapButtons(withIndex index: Int, toAlpha alpha: CGFloat, stopIndex: Int) {
        if index == stopIndex {
            isAnimating = false
            return
        }
        
        isAnimating = true
        let button = iapButtonStacks[index]
        
        // Modify the ability to click the button based on its appearance
        iapButtons[index].isEnabled = !iapButtons[index].isEnabled
        
        UIView.transition(with: button, duration: 0.15, options: [.transitionFlipFromTop], animations: {
            button.alpha = alpha
        }, completion: {
            void in
            
            var nextIndex: Int
            if stopIndex < 0 {
                nextIndex = index - 1
            } else {
                nextIndex = index + 1
            }
            self.animateIapButtons(withIndex: nextIndex, toAlpha: alpha, stopIndex: stopIndex)
        })
    }
}

extension NSMutableAttributedString {
    // Extension from Krunal on stackoverflow https://stackoverflow.com/questions/27728466/use-multiple-font-colors-in-a-single-label
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
    }
}


