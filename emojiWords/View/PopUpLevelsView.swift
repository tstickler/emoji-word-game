//
//  PopUpLevelsView.swift
//  emojiWords
//
//  Created by Tyler Stickler on 4/22/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import UIKit

class PopUpLevelsView: UIView {
    var startX = 1
    var startY = 5
    var levelButtons = [UIButton]()
    var purchaseViews = [UIView]()
    var completedLevels = [Int]()
    var shouldShowLevels = true
    weak var delegate: LevelPopUpDelegate?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawBox()
        addBlurView()
        addButtons()
        if !shouldShowLevels {
            addLevelPackPurchaseViews()
        }
    }

    func drawBox() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: startX, y: startY))
        path.addLine(to: CGPoint(x: startX - 8, y: startY + 8))
        path.addLine(to: CGPoint(x: 1, y: startY + 8))
        path.addLine(to: CGPoint(x: 1, y: 199))
        path.addLine(to: CGPoint(x: self.frame.width - 1.0, y: 199))
        path.addLine(to: CGPoint(x: self.frame.width - 1.0, y: CGFloat(startY + 8)))
        path.addLine(to: CGPoint(x: startX + 8, y: startY + 8))
        path.close()
        
        let box = CAShapeLayer()
        box.path = path.cgPath
        box.anchorPoint = .zero
        box.strokeColor = UIColor.black.cgColor
        box.fillColor = UIColor.clear.cgColor
        box.position = CGPoint(x: 0, y: 0)
        box.zPosition = 0.0
        box.lineWidth = 2.0
        self.layer.addSublayer(box)
    }
    
    func addButtons() {
        let verticalStack = UIStackView()
        verticalStack.distribution = .fillEqually
        verticalStack.spacing = 8
        verticalStack.axis = .vertical
        verticalStack.layer.zPosition = 1.0
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        for j in 0...3 {
            let stack = UIStackView()
            stack.distribution = .fillEqually
            stack.spacing = 12
            stack.axis = .horizontal
            stack.layer.zPosition = 1.0
            stack.translatesAutoresizingMaskIntoConstraints = false
            
            for i in 0...4 {
                let levelNumber = (j * 5) + (i + 1)
                
                let button = UIButton(type: .system)
                button.frame = CGRect(x: 0, y: 0, width: 90, height: 40)
                button.setTitle("\(levelNumber)", for: .normal)
                button.tag = levelNumber
                button.titleLabel?.font = UIFont(name: "VTC-GarageSale", size: 24)
                
                if completedLevels.contains(levelNumber) {
                    button.setTitleColor(.white, for: .normal)
                    button.backgroundColor = UIColor.init(red: 3/255,
                                                          green: 192/255,
                                                          blue: 60/255,
                                                          alpha: 1.0)
                } else {
                    if levelNumber % 2 == 0 {
                        button.backgroundColor = .white
                    } else {
                        button.backgroundColor = .groupTableViewBackground
                    }
                    button.setTitleColor(.black, for: .normal)
                }
                
                button.layer.borderColor = UIColor.black.cgColor
                button.layer.borderWidth = 1.75
                button.translatesAutoresizingMaskIntoConstraints = false
                stack.addArrangedSubview(button)
                if !shouldShowLevels {
                    button.alpha = 0.0
                }
                levelButtons.append(button)
                button.addTarget(self, action: #selector(levelButtonTapped), for: .touchUpInside)
            }
            
            verticalStack.addArrangedSubview(stack)
        }
        
        addSubview(verticalStack)
                
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: verticalStack,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 21))
        constraints.append(NSLayoutConstraint(item: verticalStack,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 12))
        constraints.append(NSLayoutConstraint(item: verticalStack,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: -12))
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func addBlurView() {
        let blur = UIBlurEffect(style: .regular)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.alpha = 1.0
        blurView.frame = self.bounds
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.zPosition = 1.0

        addSubview(blurView)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: blurView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 14))
        constraints.append(NSLayoutConstraint(item: blurView,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 2))
        constraints.append(NSLayoutConstraint(item: blurView,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: -2))
        constraints.append(NSLayoutConstraint(item: blurView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 184))

        NSLayoutConstraint.activate(constraints)

    }
    
    func addLevelPackPurchaseViews() {
        let label = UILabel()
        label.text = "THIS LEVEL PACK IS LOCKED!"
        label.font = UIFont(name: "VTC-GarageSale", size: 28.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.zPosition = 1.0
        purchaseViews.append(label)
        addSubview(label)
        
        let iapButton = UIButton(type: .system)
        iapButton.setTitle("$1.99", for: .normal)
        iapButton.backgroundColor = .white
        iapButton.layer.borderWidth = 2.0
        iapButton.layer.borderColor = UIColor.black.cgColor
        iapButton.setTitleColor(.black, for: .normal)
        iapButton.titleLabel?.font = UIFont(name: "VTC-GarageSale", size: 24.0)
        iapButton.addTarget(self, action: #selector(iapButtonTapped), for: .touchUpInside)
        
        let restorePurchaseButton = UIButton(type: .system)
        restorePurchaseButton.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        restorePurchaseButton.setTitle("RESTORE PURCHASE", for: .normal)
        restorePurchaseButton.setTitleColor(.black, for: .normal)
        restorePurchaseButton.layer.zPosition = 1.0
        restorePurchaseButton.titleLabel?.font = UIFont(name: "VTC-GarageSale", size: 24.0)
        restorePurchaseButton.addTarget(self, action: #selector(restorePurchaseTapped), for: .touchUpInside)
        restorePurchaseButton.translatesAutoresizingMaskIntoConstraints = false
        purchaseViews.append(restorePurchaseButton)
        addSubview(restorePurchaseButton)
        
        let gemsButton = UIButton(type: .system)
        gemsButton.setTitle("1000 GEMS", for: .normal)
        if User.shared.gemCount >= 1000 {
            gemsButton.backgroundColor = .white
        } else {
            gemsButton.backgroundColor = UIColor.init(red: 255/255,
                                                      green: 39/255,
                                                      blue: 35/255,
                                                      alpha: 1.0)
        }
        gemsButton.layer.borderWidth = 2.0
        gemsButton.layer.borderColor = UIColor.black.cgColor
        gemsButton.setTitleColor(.black, for: .normal)
        gemsButton.titleLabel?.font = UIFont(name: "VTC-GarageSale", size: 24.0)
        gemsButton.translatesAutoresizingMaskIntoConstraints = false
        gemsButton.addTarget(self, action: #selector(gemsButtonTapped), for: .touchUpInside)
        
        let orLabel = UILabel()
        orLabel.text = "OR"
        orLabel.font = UIFont(name: "VTC-GarageSale", size: 30.0)

        let stack = UIStackView()
        stack.distribution = .equalSpacing
        stack.spacing = 10
        stack.axis = .horizontal
        stack.layer.zPosition = 1.0
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        stack.addArrangedSubview(iapButton)
        stack.addArrangedSubview(orLabel)
        stack.addArrangedSubview(gemsButton)
        purchaseViews.append(stack)
        
        let gemStack = UIStackView()
        gemStack.distribution = .equalSpacing
        gemStack.spacing = 4
        gemStack.axis = .horizontal
        gemStack.layer.zPosition = 1.0
        gemStack.translatesAutoresizingMaskIntoConstraints = false
        purchaseViews.append(gemStack)
        addSubview(gemStack)
        
        let gem = UIImage(named: "gem")
        let gemView = UIImageView(image: gem)
        
        let gemCount = UILabel()
        gemCount.text = String(User.shared.gemCount)
        gemCount.font = UIFont(name: "VTC-GarageSale", size: 22.0)
        gemCount.translatesAutoresizingMaskIntoConstraints = false
        gemCount.layer.zPosition = 1.0

        gemStack.addArrangedSubview(gemView)
        gemStack.addArrangedSubview(gemCount)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: label,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 50))
        constraints.append(NSLayoutConstraint(item: label,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: stack,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: stack,
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 28))
        constraints.append(NSLayoutConstraint(item: gemsButton,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: 100))
        constraints.append(NSLayoutConstraint(item: iapButton,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: 100))
        constraints.append(NSLayoutConstraint(item: gemView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1.0,
                                              constant: 20))
        constraints.append(NSLayoutConstraint(item: gemView,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .width,
                                              multiplier: 1.0,
                                              constant: 20))
        constraints.append(NSLayoutConstraint(item: gemStack,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: -8))
        constraints.append(NSLayoutConstraint(item: gemView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 16))
        constraints.append(NSLayoutConstraint(item: restorePurchaseButton,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: restorePurchaseButton,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        NSLayoutConstraint.activate(constraints)

    }
    
    @objc func levelButtonTapped(_ sender: UIButton) {
        delegate?.handleLevelButton(level: sender.tag)
    }
    
    @objc func iapButtonTapped(_ sender: UIButton) {
        delegate?.handleIapButton()
    }
    
    @objc func gemsButtonTapped(_ sender: UIButton) {
        delegate?.handleGemsButton()
    }
    
    @objc func restorePurchaseTapped(_ sender: UIButton) {
        delegate?.handleRestorePurchase()
    }
}
