//
//  LevelsViewController.swift
//  emojiWords
//
//  Created by Tyler Stickler on 4/5/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import UIKit

class LevelsViewController: UIViewController {
    private var levelString = ""
    private var levelPackKey: String!
    private var levelIndex: Int!
    private var levelPackButton: UIButton!
    private var popUpLevels: PopUpLevelsView?
    
    @IBOutlet weak var circle: UIImageView!
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet var levelPacksStacks: [UIStackView]!
    @IBOutlet var levelPacksContainerViews: [UIView]!
    
    private var animationIsOccuring = false
    @IBAction func levelPackSelected(_ sender: UIButton) {
        if animationIsOccuring {
            return
        }
        
        levelPackKey = sender.titleLabel?.text
        
        // Find the container below the button's stack and its height constraint
        // This is where the pop up will be contained contained
        // The height constraint needs to be known to be animated
        guard let containerView = findContainerForPopUp(relatedTo: sender),
            let containerViewHeight = findContainerHeightConstraint(onView: containerView) else { return }

        // Create and add pop up to the container
        popUpLevels = PopUpLevelsView()
        guard let popUpLevels = popUpLevels else { return }
        popUpLevels.delegate = self
        setUpPopUp(onView: popUpLevels, superview: containerView)
        InAppPurchase.shared.delegate = self
        popUpLevels.startX = Int(sender.center.x)

        // Find containers that need to be collapsed/have views removed
        var containersToBeEmptied = [UIView]()
        for container in levelPacksContainerViews {
            // If the height of a container is greater than 0, then it needs to be collapsed
            // and any views inside should be removed
            if let height = findContainerHeightConstraint(onView: container) {
                if height.constant > 0 {
                    height.constant = 0
                    containersToBeEmptied.append(container)
                }
            }
        }
        
        // Set height for current container
        containerViewHeight.constant = 200
        
        // Find out what button/row was tapped
        for i in 0..<containersToBeEmptied.count {
            // If the current container is flagged to be emptied then
            // the user has tapped the same row twice
            if containersToBeEmptied[i] == containerView {
                // There will be two subviews in our container in this case.
                // The old pop up from the previous display and our current pop up
                if containerView.subviews.count > 1 {
                    let popUpOne = containerView.subviews[0] as! PopUpLevelsView
                    let popUpTwo = containerView.subviews[1] as! PopUpLevelsView

                    // If the old pop up is at the same spot as the current one
                    // then the user has tapped the same button.
                    // In this case, just close the pop up
                    if popUpOne.startX == popUpTwo.startX {
                        containerViewHeight.constant = 0
                        containersToBeEmptied.append(containerView)
                    } else {
                        // If the tap was in the same row but not the same button
                        // then the user is trying to open a different pack in the same
                        // row. In this case, subview at index 0 is the old subview and should
                        // be removed. This container should not be completely emptied because
                        // the user is just trying to access a different pack in the same row
                        containerView.subviews[0].removeFromSuperview()
                        containersToBeEmptied.remove(at: i)
                    }
                }
            }
        }
        
        if !User.shared.unlockedLevelPacks.contains(levelPackKey) {
            popUpLevels.shouldShowLevels = false
        }
        
        popUpLevels.completedLevels = User.shared.completedLevels[levelPackKey] ?? [Int]()
        
        UIView.animate(withDuration: 0.2, animations: {
            self.animationIsOccuring = true
            self.view.layoutIfNeeded()
            
        }, completion: {
            void in

            self.animationIsOccuring = false
            
            // Resize the content view of the scroll view
            var contentRect = CGRect(x: 0, y: 0, width: 0, height: 0)
            for view in self.scroller.subviews {
                contentRect = contentRect.union((view).frame);
            }
            self.scroller.contentSize = contentRect.size;

            // Remove old pop ups from containers
            for container in containersToBeEmptied {
                for subview in container.subviews {
                    subview.removeFromSuperview()
                }
            }
        })
        
        levelPackButton = sender
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToGameView" {
            let gameViewController: GameViewController = segue.destination as! GameViewController
            gameViewController.gameString = levelString
            gameViewController.levelPackName = levelPackKey.capitalized
            gameViewController.levelNumber = levelIndex + 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLevelPackButtons()
        spinCircle(withDelay: 0.0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Simulates a pack close after the view has disappeared.
        levelPackButton.sendActions(for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpLevelPackButtons()
    }
    
    func setUpLevelPackButtons() {
        for stackView in levelPacksStacks {
            for button in stackView.subviews as! [UIButton] {
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.black.cgColor
                button.imageView?.contentMode = .scaleAspectFit
                
                // Probably move this to viewdidappear, that way returning to the levels screen will update if pack was completed
                if let buttonTitleLabel = button.titleLabel, let levelPackName = buttonTitleLabel.text {
                    if !User.shared.unlockedLevelPacks.contains(levelPackName) {
                        button.backgroundColor = UIColor.init(red: 255/255,
                                                              green: 39/255,
                                                              blue: 35/255,
                                                              alpha: 1.0)
                    }
                    
                    if let completedLevelsForPack = User.shared.completedLevels[levelPackName] {
                        if completedLevelsForPack.count == 20 {
                            button.backgroundColor = UIColor.init(red: 3/255,
                                                                  green: 192/255,
                                                                  blue: 60/255,
                                                                  alpha: 1.0)
                        }
                    }
                }
            }
        }
    }
    
    func findContainerForPopUp(relatedTo sender: UIButton) -> UIView? {
        for i in 0..<levelPacksStacks.count {
            if levelPacksStacks[i] == sender.superview {
                return levelPacksContainerViews[i]
            }
        }
        
        return nil
    }
    
    func findContainerHeightConstraint(onView containerView: UIView) -> NSLayoutConstraint? {
        for constraint in containerView.constraints {
            if constraint.firstAttribute == .height {
                return constraint
            }
        }
        
        return nil
    }
    
    func setUpPopUp(onView popUp: PopUpLevelsView, superview: UIView) {
        popUp.clipsToBounds = true
        popUp.translatesAutoresizingMaskIntoConstraints = false
        superview.addSubview(popUp)
        
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: popUp,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: superview,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: popUp,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: superview,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: popUp,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: superview,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: popUp,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: superview,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: 0))
        NSLayoutConstraint.activate(constraints)
        
        superview.layoutIfNeeded()
    }
    
    func spinCircle(withDelay delay: Double) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.beginTime = CACurrentMediaTime() + delay
        
        rotateAnimation.fromValue = 0.0
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.toValue = CGFloat(.pi * 2.0)
        rotateAnimation.duration = 3.0
        rotateAnimation.autoreverses = false
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        
        circle.layer.add(rotateAnimation, forKey: "rotate")
    }
}

extension LevelsViewController: LevelPopUpDelegate, InAppPurchaseDelegate {
    func handleRestorePurchase() {
        InAppPurchase.shared.restorePurchases()
    }
    
    func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        
        topMostViewController?.present(alert, animated: true, completion: nil)
    }
    
    func redeemGemPurchase(gemCount: Int) {
        // No implementation needed
    }
    
    func levelPackPurchaseCompleted() {
        User.shared.unlockedLevelPacks.append(levelPackKey)
        GameData.shared.defaults.set(User.shared.unlockedLevelPacks, forKey: User.shared.unlockedLevelPacksKey)

        changePackBackground()
        showLevels()
    }
    
    func handleLevelButton(level: Int) {
        levelIndex = level - 1
        
        if let levels = GameData.shared.levels, let levelPack = levels[levelPackKey] {
            levelString = levelPack[levelIndex]
            performSegue(withIdentifier: "segueToGameView", sender: self)
        }
    }
    
    func handleIapButton() {
        guard let levelPackName = levelPackKey else { return }
        let iapString = "com.tstick.Spinmoji.\(levelPackName.capitalized)Pack"
        let iap = IAP(rawValue: iapString)
        
        guard let packPurchase = iap else { return }
        InAppPurchase.shared.purchaseProduct(product: packPurchase)
    }
    
    func handleGemsButton() {
        guard let _ = levelPackKey else { return }
        if User.shared.gemCount < 1000 {
            return
        }
        
        User.shared.gemCount -= 1000
        GameData.shared.defaults.set(User.shared.gemCount, forKey: User.shared.gemKey)
        
        levelPackPurchaseCompleted()
    }
    
    func showLevels() {
        if let popUpLevels = popUpLevels {
            UIView.animate(withDuration: 0.5) {
                for view in popUpLevels.purchaseViews {
                    view.alpha = 0
                }
                
                for button in popUpLevels.levelButtons {
                    button.alpha = 1.0
                }
            }
        }
    }
    
    func changePackBackground() {
        for stack in levelPacksStacks {
            for levelPack in stack.arrangedSubviews  {
                let pack = levelPack as? UIButton
                
                if pack?.titleLabel?.text == levelPackKey {
                    UIView.animate(withDuration: 0.5) {
                        levelPack.backgroundColor = .white
                    }
                }
            }
        }
    }
}
