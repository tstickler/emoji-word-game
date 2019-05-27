//
//  HomeViewController.swift
//  emojiWords
//
//  Created by Tyler Stickler on 5/7/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var circle: UIImageView!
    @IBOutlet weak var cover: UIView!
    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var circleWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var circleTopConstraint: NSLayoutConstraint!
    @IBOutlet var homeViews: [UIView]!
    var initialAnimation = true
    var topConstraint: CGFloat!
    var leadingConstraint: CGFloat!
    
    @IBAction func playButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "segueToLevels", sender: self)
    }
    
    // MARK: - Init functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSoundButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setSoundButtonImage()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if initialAnimation {
            animateStart()
            initialAnimation = false
        }
    }
    
    // MARK: - Circle animation function
    func animateStart() {
        correctCircleOffset()
        moveCircle()
        spinCircle(withDelay: 0.25)
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
    
    func moveCircle() {
        UIView.animate(withDuration: 1.0, delay: 1.0, options: [], animations: { self.cover.alpha = 0 }, completion: {
            void in
            
            self.topConstraint = self.circleTopConstraint.constant
            self.leadingConstraint = self.circleLeadingConstraint.constant
            
            self.circleWidthConstraint.constant = 75
            self.circleHeightConstraint.constant = 75
            self.circleLeadingConstraint.constant = 9.5
            self.circleTopConstraint.constant = 25
            
            
            UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
                self.view.layoutIfNeeded()
                for view in self.homeViews {
                    view.alpha = 1.0
                }
            }, completion: nil)
        })
    }
    
    func correctCircleOffset() {
        let phoneCenterY = view.frame.midY
        let circleCenterY = circle.frame.midY
        
        circleTopConstraint.constant -= (circleCenterY - phoneCenterY)
    }
    
    // MARK: - Sound Button Functions
    func setUpSoundButton() {
        soundButton.layer.borderColor = UIColor.black.cgColor
        soundButton.layer.borderWidth = 4.0
        
        playButton.layer.borderColor = UIColor.black.cgColor
        playButton.layer.borderWidth = 4.0

        setSoundButtonImage()
    }
    
    func setSoundButtonImage() {
        var image: UIImage?
        if User.shared.prefersSoundEffects {
            image = UIImage(named: "speaker")
        } else {
            image = UIImage(named: "muted-speaker")
        }
        
        guard let speakerImage = image else { return }
        soundButton.setImage(speakerImage, for: .normal)
        
    }
    
    @IBAction func soundButtonTapped(_ sender: UIButton) {
        User.shared.prefersSoundEffects = !User.shared.prefersSoundEffects
        GameData.shared.defaults.set(User.shared.prefersSoundEffects, forKey: User.shared.soundKey)
        
        setSoundButtonImage()
    }
}
