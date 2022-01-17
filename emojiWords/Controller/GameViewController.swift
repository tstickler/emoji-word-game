//
//  GameViewController.swift
//  emojiWords
//
//  Created by Tyler Stickler on 3/21/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GameViewController: UIViewController {
    enum AdType {
        case interstitial
        case rewarded
    }

    // MARK: - Properties
    var circles = [SegmentedCircleView]()
    var popUp: PopUpInformationView?
    var game: WordGame!
    var timer: Timer!
    var gameString: String!
    var correctAnswerSpots: [Int]!
    var correctAnswerKey: String!
    var hintRevealed: [Int]!
    var hintKey: String!
    var levelPackName = ""
    var levelNumber = 0
    var isRecognizingPopUpGesture = false
    var dimmer: UIView?
    var menu: MenuView?
    var returningFromHelp = false
    var returningFromAd = false
    var startNextGame = false

    private var interstitial: GADInterstitialAd?
    private var rewardedAd: GADRewardedAd?
    private var adType: AdType?

    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var gemCountLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var singleClueView: UIView!
    @IBOutlet weak var levelPackImage: UIImageView!
    @IBOutlet var emojiLabels: [UILabel]!
    @IBOutlet var wordCountLabels: [UILabel]!
    @IBOutlet weak var gameOverView: UIView!
    @IBOutlet weak var gameOverPackText: UILabel!
    @IBOutlet weak var gameOverButton: UIButton!
    @IBOutlet weak var helpYes: UIButton!
    @IBOutlet weak var helpNo: UIButton!
    @IBOutlet weak var helpView: UIView!
    
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var guessFrame: UIView!
    @IBOutlet weak var guessText: UILabel!
    @IBOutlet weak var guessClear: UIButton!
    
    @IBOutlet weak var circleOne: SegmentedCircleView!
    @IBOutlet weak var circleTwo: SegmentedCircleView!
    @IBOutlet weak var circleThree: SegmentedCircleView!
    @IBOutlet weak var circleFour: SegmentedCircleView!
    
    private let redColor = UIColor.init(red: 255/255,
                                        green: 39/255,
                                        blue: 35/255,
                                        alpha: 1.0)
    private let blueColor = UIColor.init(red: 63/255,
                                         green: 123/255,
                                         blue: 182/255,
                                         alpha: 1.0)
    private let purpleColor = UIColor.init(red: 150/255,
                                           green: 111/255,
                                           blue: 214/255,
                                           alpha: 1.0)
    private let orangeColor = UIColor.init(red: 240/255,
                                           green: 149/255,
                                           blue: 54/255,
                                           alpha: 1.0)
    private let greenColor = UIColor.init(red: 3/255,
                                          green: 192/255,
                                          blue: 60/255,
                                          alpha: 1.0)
    private let pinkColor = UIColor.init(red: 255/255,
                                         green: 127/255,
                                         blue: 157/255,
                                         alpha: 1.0)
    private let grayColor = UIColor.init(red: 127/255,
                                         green: 127/255,
                                         blue: 127/255,
                                         alpha: 1.0)
    
    // MARK: - init functions
    override func viewDidLoad() {
        super.viewDidLoad()
        game = WordGame(gameString: gameString)
        game.delegate = self
        
        initializeKeys()
        fillFromDefaults()
        setUpCircles()
        setUpGuessArea()
        setUpTopBar()
        initAds()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if returningFromHelp || returningFromAd {
            returningFromHelp = false
            returningFromAd = false
            return
        }
        
        game.startGame()
        game.fillCorrectAnswers(correctAnswerSpots)
        setUpClueArea()
        animateGameStart()
        for circle in circles {
            circle.centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        }
    }
    
    func initializeKeys() {
        correctAnswerKey = "\(levelPackName.lowercased())_\(levelNumber)_correct"
        hintKey = "\(levelPackName.lowercased())_\(levelNumber)_hint"
    }
    
    func fillFromDefaults() {
        correctAnswerSpots = GameData.shared.defaults.array(forKey: correctAnswerKey) as? [Int] ?? [Int]()
        hintRevealed = GameData.shared.defaults.array(forKey: hintKey) as? [Int] ?? [Int]()
    }

    // MARK: - Ad Setup
    func initAds() {
        loadInterstitialAd()
        loadRewardedAd()
    }

    func loadInterstitialAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: EnvironmentManager.shared.interstitialAdUnitId,
                               request: request) { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }

            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
        }
    }

    func loadRewardedAd() {
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: EnvironmentManager.shared.rewardAdUnitId,
                           request: request) { [self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }

            rewardedAd = ad
            rewardedAd?.fullScreenContentDelegate = self
        }
    }

    func showInterstitialAd() {
        if interstitial != nil {
            adType = .interstitial
            interstitial!.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready")
        }
    }

    func showRewardedAd() {
        if rewardedAd != nil {
            adType = .rewarded
            rewardedAd?.present(fromRootViewController: self) {
                if let popUp = self.popUp {
                    popUp.hintIsRevealed = true
                    if !self.hintRevealed.contains(popUp.infoForClue) {
                        self.hintRevealed.append(popUp.infoForClue)
                        GameData.shared.defaults.set(self.hintRevealed, forKey: self.hintKey)
                    }

                    UIView.animate(withDuration: 0.6) {
                        popUp.blurView.alpha = 0.0
                    }
                }
            }
        }
    }
    
    // MARK: - Help View Functions
    func setUpHelpView() {
        helpNo.layer.borderColor = UIColor.black.cgColor
        helpNo.layer.borderWidth = 2.0
        
        helpYes.layer.borderColor = UIColor.black.cgColor
        helpYes.layer.borderWidth = 2.0

        helpView.layer.borderColor = UIColor.black.cgColor
        helpView.layer.zPosition = 1.0
        helpView.layer.borderWidth = 4.0
        
        addDimmer()
        
        view.bringSubviewToFront(helpView)
    }
    
    func showHelpPrompt() {
        returningFromHelp = true
        User.shared.helpSeen = true
        GameData.shared.defaults.set(User.shared.helpSeen, forKey: User.shared.helpKey)

        UIView.animate(withDuration: 0.75, animations: {
            self.setUpHelpView()
            
            if let dimmer = self.dimmer {
                dimmer.alpha = 0.8
                self.helpView.alpha = 1.0
            }
        })
    }
    
    @IBAction func helpYesTapped(_ sender: Any) {
        performSegue(withIdentifier: "segueToHelp", sender: self)
        UIView.animate(withDuration: 0.15, animations: {
            self.helpView.alpha = 0.0
            
            if let dimmer = self.dimmer {
                dimmer.alpha = 0.0
            }
        })
    }
    
    @IBAction func helpNoTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.75, animations: {
            self.helpView.alpha = 0.0
            
            if let dimmer = self.dimmer {
                dimmer.alpha = 0.0
            }
        })
    }
    
    // MARK: - Top Bar Functions
    private func setUpTopBar() {
        setGemCount(toCount: User.shared.gemCount)
        setUpLevelName()
        
        topView.layer.borderColor = UIColor.black.cgColor
        topView.layer.borderWidth = 2
    }
    
    private func setUpLevelName() {
        levelLabel.text = "\(levelPackName) - \(levelNumber)"
    }
    
    private func setGemCount(toCount count: Int) {
        let differenceBetweenCounts = count - User.shared.gemCount
        
        if differenceBetweenCounts > 0 {
            // User has gained gems
            gemCountLabel.text = "+\(differenceBetweenCounts)"
            animateGemCountChange(gemsIncreased: true)
        } else if differenceBetweenCounts < 0 {
            // User has lost gems
            gemCountLabel.text = "\(differenceBetweenCounts)"
            animateGemCountChange(gemsIncreased: false)
        } else {
            // User gems are even
            if count > 9999 {
                gemCountLabel.text = "9999+"
            } else {
                gemCountLabel.text = String(count)
            }
            gemCountLabel.textColor = .black
        }
        
        User.shared.gemCount = count
    }
    
    private func animateGemCountChange(gemsIncreased: Bool) {
        var color: UIColor
        if gemsIncreased {
            color = greenColor
        } else {
            color = redColor
        }
        
        gemCountLabel.layer.removeAllAnimations()
        
        UIView.transition(with: gemCountLabel, duration: 0.4, options: .transitionFlipFromTop, animations: {
            // User is shown a message
            self.gemCountLabel.textColor = color
        }, completion: {
            (Void) in
            // Fade out the message
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600), execute: {
                UIView.transition(with: self.gemCountLabel, duration: 0.4, options: .transitionFlipFromBottom, animations: {
                    self.gemCountLabel.textColor = .black
                    
                    if User.shared.gemCount > 9999 {
                        self.gemCountLabel.text = "9999+"
                    } else {
                        self.gemCountLabel.text = String(User.shared.gemCount)
                    }
                }, completion: nil)
            })
        })
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        popUp?.closeFrame()
        
        addDimmer()
        let menuOffset: CGFloat = 10
        let menuWidth: CGFloat = 200
        let menuHeight = view.frame.height + menuOffset
        menu = MenuView(frame: CGRect(x: -menuWidth - menuOffset, y: -5, width: menuWidth + menuOffset, height: menuHeight))
        menu!.delegate = self
        InAppPurchase.shared.delegate = self
        view.addSubview(menu!)

        AudioPlayer.shared.playSoundEffect(soundEffect: "menuOpen", ext: "mp3")
        animateMenu(isShowing: true)
    }
    
    func closeMenu(completion: (() -> Void)? = nil) {
        AudioPlayer.shared.playSoundEffect(soundEffect: "menuClose", ext: "mp3")
        animateMenu(isShowing: false, animationCompletion: completion)
    }
    
    func addDimmer() {
        dimmer = UIView(frame: view.frame)
        guard let dimmer = dimmer else { return }
        dimmer.backgroundColor = .black
        dimmer.alpha = 0
        dimmer.layer.zPosition = 0.99
        view.addSubview(dimmer)
    }
    
    func animateMenu(isShowing: Bool, animationCompletion: (() -> Void)? = nil) {
        let xPosOfView: CGFloat = isShowing ? -10 : -210
        let dimmerAlpha: CGFloat = isShowing ? 0.65 : 0
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.menu?.frame = CGRect(x: xPosOfView, y: self.menu!.frame.minY, width: self.menu!.frame.width, height: self.menu!.frame.height)
            

        }, completion: {
            void in
            if !isShowing {
                self.menu?.removeFromSuperview()
                self.menu = nil
            }
        })
        
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.dimmer?.alpha = dimmerAlpha
        }, completion: {
            void in
            if !isShowing {
                self.dimmer?.removeFromSuperview()
                self.dimmer = nil
                
                animationCompletion?()
            }
        })
    }
    
    // MARK: - Circles Functions
    private func setUpCircles() {
        circleOne.numOfSegments = game.sectorsPerWheel
        circleOne.setCircleColor(withColor: redColor.cgColor)
        
        circleTwo.numOfSegments = game.sectorsPerWheel
        circleTwo.setCircleColor(withColor: blueColor.cgColor)
        
        circleThree.numOfSegments = game.sectorsPerWheel
        circleThree.setCircleColor(withColor: purpleColor.cgColor)

        circleFour.numOfSegments = game.sectorsPerWheel
        circleFour.setCircleColor(withColor: orangeColor.cgColor)
        
        circles.append(circleOne)
        circles.append(circleTwo)
        circles.append(circleThree)
        circles.append(circleFour)
    }
    
    @objc private func centerButtonTapped(sender: UIButton) {
        let parentCircle = sender.superview as! SegmentedCircleView
        let sector = determineCurrentSector(parentCircle)
        var circleNumber = -1
        
        // Prevent adding text while wheels are spinning
        if isCircleSpinning(circle: parentCircle) {
            return
        }
        
        // Figure out which number the circle correlates to
        for i in 0..<circles.count {
            if circles[i] == parentCircle {
                circleNumber = i
            }
        }
        
        // Somehow the circle was not found, don't do anything
        if circleNumber == -1 {
            return
        }

        AudioPlayer.shared.playSoundEffect(soundEffect: "addText", ext: "wav")
        modifyGuessButton(withModification: "guess")
        game.addTextToAnswer(circleNumber: circleNumber, sectorNumber: sector)
        
        popUp?.closeFrame()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let popUp = popUp {
            if touches.first?.view != popUp && touches.first?.view != popUp.blurView.contentView {
                popUp.closeFrame()
            }
        }
        
        if let dimmer = dimmer {
            if touches.first?.view == dimmer {
                if let _ = menu {
                    closeMenu()
                }
            }
        }
        
        for circle in circles {
            if isCircleSpinning(circle: circle) {
                return
            }
        }
        
        let touch = touches.first
        let position = touch!.location(in: self.view)
        var touchedCircle: SegmentedCircleView?
        for circle in circles {
            if circle == touch!.view {
                touchedCircle = circle
            }
        }
        
        if let touchedCircle = touchedCircle {
            
            let target = touchedCircle.center
            let angle = atan2(target.y-position.y, target.x-position.x)
            
            touchedCircle.oldAngle = angle
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for circle in circles {
            if isCircleSpinning(circle: circle) {
                return
            }
        }
        
        let touch = touches.first
        var touchedCircle: SegmentedCircleView?
        for circle in circles {
            if circle == touch!.view {
                touchedCircle = circle
            }
        }
        
        if let touchedCircle = touchedCircle {
            
            let sector = determineCurrentSector(touchedCircle)
            let angle = snapAngle(to: sector, withCircleSize: touchedCircle.numOfSegments)
            
            
            UIView.animate(withDuration: 0.15) {
                touchedCircle.transform = CGAffineTransform(rotationAngle: angle)
                
                for label in touchedCircle.labels {
                    label.transform = touchedCircle.transform.inverted()
                }
                touchedCircle.centerButton.transform = touchedCircle.transform.inverted()
            }
            
            touchedCircle.movedDistance = angle
            
            highlightSector(onCircle: touchedCircle)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for circle in circles {
            if isCircleSpinning(circle: circle) {
                return
            }
        }
        
        let touch = touches.first
        var touchedCircle: SegmentedCircleView?
        for circle in circles {
            if circle == touch!.view {
                touchedCircle = circle
            }
        }
        
        if let touchedCircle = touchedCircle {
            
            let oldAngle = touchedCircle.oldAngle
            let movedDistance = touchedCircle.movedDistance
            let position = touch!.location(in: self.view)
            let target = touchedCircle.center
            var angle = atan2(target.y-position.y, target.x-position.x)
            if angle < 0 {
                angle += 2 * .pi
            }
            
            touchedCircle.transform = CGAffineTransform(rotationAngle: angle - oldAngle + movedDistance)
            
            for label in touchedCircle.labels {
                label.transform = touchedCircle.transform.inverted()
            }
            
            touchedCircle.centerButton.transform = touchedCircle.transform.inverted()
            
            highlightSector(onCircle: touchedCircle)
        }
    }
    
    func highlightSector(onCircle circle: SegmentedCircleView) {
        for i in 0..<circle.numOfSegments {
            if i == determineCurrentSector(circle) {
                circle.shouldHighlightSector(shouldHighlight: true, sector: i)
                
                if determineCurrentSector(circle) != circle.currentSector {
                    // Only make feedback if the circle isn't doing spin animation
                    if !isCircleSpinning(circle: circle) {
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                    }
                    
                    circle.currentSector = determineCurrentSector(circle)
                }
            } else {
                circle.shouldHighlightSector(shouldHighlight: false, sector: i)
            }
        }
    }
    
    func determineCurrentSector(_ touchedCircle: SegmentedCircleView) -> Int {
        var sector = 0
        
        var currentAngle = atan2f(Float(touchedCircle.transform.b), Float(touchedCircle.transform.a));
        if currentAngle < 0 {
            currentAngle += 2 * .pi
        }
        
        if touchedCircle.numOfSegments == 3 {
            if currentAngle >= .pi / 3 && currentAngle < 5 * .pi / 3 {
                sector = 0
            }
            
            if currentAngle >= .pi / 3 && currentAngle < .pi {
                sector = 1
            }
            
            if currentAngle >= 5 * .pi / 3 || currentAngle < .pi / 3 {
                sector = 2
            }
        }
        
        if touchedCircle.numOfSegments == 4 {
            if currentAngle >= 5 * .pi / 4 && currentAngle < 7 * .pi / 4 {
                sector = 0
            }
            
            if currentAngle >= 3 * .pi / 4 && currentAngle < 5 * .pi / 4 {
                sector = 1
            }
            
            if currentAngle >= .pi / 4 && currentAngle < 3 * .pi / 4 {
                sector = 2
            }
            
            if currentAngle >= 7 * .pi / 4 || currentAngle < .pi / 4  {
                sector = 3
            }
        }
        
        if touchedCircle.numOfSegments == 5 {
            if currentAngle >= .pi / 5 && currentAngle < 3 * .pi / 5 {
                sector = 3
            }
            
            if currentAngle >= 3 * .pi / 5 && currentAngle < .pi {
                sector = 2
            }
            
            if currentAngle >= .pi && currentAngle < 7 * .pi / 5 {
                sector = 1
            }
            
            if currentAngle >= 7 * .pi / 5 && currentAngle < 9 * .pi / 5 {
                sector = 0
            }
            
            if currentAngle >= 9 * .pi / 5 || currentAngle < .pi / 5  {
                sector = 4
            }
        }
        
        if touchedCircle.numOfSegments == 6 {
            if currentAngle >= 3 * .pi / 2 && currentAngle < 11 * .pi / 6 {
                sector = 0
            }
            
            if currentAngle >= 7 * .pi / 6 && currentAngle < 3 * .pi / 2 {
                sector = 1
            }
            
            if currentAngle >= 5 * .pi / 6 && currentAngle < 7 * .pi / 6 {
                sector = 2
            }
            
            if currentAngle >= .pi / 2 && currentAngle < 5 * .pi / 6 {
                sector = 3
            }
            
            if currentAngle >= .pi / 6 && currentAngle < .pi / 2 {
                sector = 4
            }
            
            if currentAngle <= .pi / 6 || currentAngle > 11 * .pi / 6 {
                sector = 5
            }
        }
        
        return sector
    }
    
    func snapAngle(to sector: Int, withCircleSize totalSectors: Int) -> CGFloat {
        var angle: CGFloat = 0.0
        
        switch totalSectors {
        case 3:
            switch sector {
            case 0:
                angle = 4 * .pi / 3
            case 1:
                angle = 2 * .pi / 3
            case 2:
                angle = 2 * .pi
            default:
                break
            }
        case 4:
            switch  sector {
            case 0:
                angle = 3 * .pi / 2
            case 1:
                angle = .pi
            case 2:
                angle = .pi / 2
            case 3:
                angle = 2 * .pi
            default:
                break
            }
        case 5:
            switch  sector {
            case 0:
                angle = 8 * .pi / 5
            case 1:
                angle = 6 * .pi / 5
            case 2:
                angle = 4 * .pi / 5
            case 3:
                angle = 2 * .pi / 5
            case 4:
                angle = 0
            default:
                break
            }
        case 6:
            switch sector {
            case 0:
                angle = 5 * .pi / 3
            case 1:
                angle = 4 * .pi / 3
            case 2:
                angle = .pi
            case 3:
                angle = 2 * .pi / 3
            case 4:
                angle = .pi / 3
            case 5:
                angle = 2 * .pi
            default:
                break
            }
        default:
            break
        }
        
        return angle
    }
    

    // MARK: - Guess Area Functions
    private func setUpGuessArea() {
        levelPackImage.image = UIImage(named: "\(levelPackName.lowercased())")
        
        guessButton.layer.borderWidth = 2
        guessButton.layer.borderColor = UIColor.black.cgColor
        
        guessFrame.layer.borderWidth = 2
        guessFrame.layer.borderColor = UIColor.black.cgColor
        
        guessClear.layer.borderWidth = 1
        guessClear.layer.borderColor = UIColor.black.cgColor
        
        modifyGuessButton(withModification: "spin")
    }
    
    @IBAction func guessClearTapped(_ sender: Any) {
        game.clearGuess()
        
        popUp?.closeFrame()
    }
    
    @IBAction func guessTapped(_ sender: Any) {
        if guessText.text! == "" {
            setUpTimer()
            modifyGuessButton(withModification: "disabled")
            spinCircles()
        } else {
            game.submitGuess()
        }

        popUp?.closeFrame()
    }
    
    func modifyGuessButton(withModification modification: String) {
        if modification == "guess" {
            guessButton.backgroundColor = greenColor
            guessButton.setTitle("GUESS", for: .normal)
            guessButton.isEnabled = true
        } else if modification == "spin" {
            guessButton.backgroundColor = pinkColor
            guessButton.setTitle("SPIN", for: .normal)
            guessButton.isEnabled = true
        } else if modification == "disabled" {
            guessButton.backgroundColor = grayColor
            guessButton.setTitle("SPIN", for: .normal)
            guessButton.isEnabled = false
        }
    }
    
    // MARK: - Clue Area and Pop Up View Functions
    func setUpClueArea() {
        levelLabel.layer.borderColor = UIColor.clear.cgColor
        levelLabel.layer.borderWidth = 2
        
        for i in 0..<emojiLabels.count {
            setUpClueLabel(label: emojiLabels[i], position: i)
            setUpClueLabel(label: wordCountLabels[i], position: i)
        }
    }
    
    func setUpClueLabel(label: UILabel, position: Int) {
        label.isUserInteractionEnabled = true
        
        // Tag will be used to retrieve hint info
        label.tag = position
        
        // Add long press recognizer to the label to initiate pop up
        addLabelGestureRecognizer(onLabel: label)
    }
    func addLabelGestureRecognizer(onLabel label: UILabel) {
        let hold = UILongPressGestureRecognizer(target: self, action: #selector(handlePopUp))
        hold.minimumPressDuration = 0.35
        label.addGestureRecognizer(hold)
    }
    
    @objc func handlePopUp(sender: UITapGestureRecognizer?) {
        if let sender = sender, var senderView = sender.view {
            switch sender.state {
            case.began:
                // Prevent the user from opening multiple frames at once
                // Only recognize the gesture if no other is occurring
                if isRecognizingPopUpGesture {
                    return
                }
                
                isRecognizingPopUpGesture = true
                
                // If the word count label was tapped, make the corresponding emoji label the sender instead
                // This ensures that the pop up frame is placed in the same correct location every time
                if wordCountLabels.contains(senderView as! UILabel) {
                    for label in emojiLabels {
                        if label.tag == senderView.tag {
                            senderView = label
                        }
                    }
                }
                
                // Determine location for the pop up
                // Convert location of the view into the root view
                let frame = senderView.convert(senderView.frame, to: self.view)
                let xLoc = frame.minX + 20
                let yLoc = frame.maxY - 12
                
                // Add pop up to the view
                popUp = PopUpInformationView.init(frame: CGRect(x: xLoc, y: yLoc, width: 250, height: 200))
                game!.getClueInformation(clueIndex: senderView.tag)
                
                if let popUp = popUp {
                    popUp.layer.zPosition = 1.0
                    popUp.alpha = 0
                    popUp.delegate = self
                    
                    popUp.infoForClue = senderView.tag
                    if hintRevealed.contains(senderView.tag) {
                        popUp.hintIsRevealed = true
                    }
                    if correctAnswerSpots.contains(senderView.tag) {
                        popUp.wordIsRevealed = true
                    }
                    view.addSubview(popUp)
                    
                    UIView.animate(withDuration: 0.25) {
                        popUp.alpha = 1
                    }
                }
            case .ended, .cancelled:
                isRecognizingPopUpGesture = false
            default:
                return
            }
        }
    }
    
    @objc private func revealButtonTapped(sender: UIButton) {
        
    }
    
    // MARK: - Game Over functions
    func setUpGameOverView() {
        addDimmer()

        view.bringSubviewToFront(gameOverView)
        gameOverView.layer.zPosition = 1.0
        gameOverView.layer.borderColor = greenColor.cgColor
        gameOverView.layer.borderWidth = 4.0
        gameOverPackText.text = "\(levelPackName.uppercased()) PACK"
        
        gameOverButton.layer.borderColor = UIColor.black.cgColor
        gameOverButton.layer.borderWidth = 2.0
    }

    func gameOver() {
        setGemCount(toCount: User.shared.gemCount + 5)
        modifyGuessButton(withModification: "disabled")
        AudioPlayer.shared.playSoundEffect(soundEffect: "gameOver", ext: "aif")
        if let popUp = popUp {
            popUp.closeFrame()
        }

        for spot in 0..<emojiLabels.count {
            UIView.transition(with: self.emojiLabels[spot].superview!, duration: 3.0, options: [.transitionFlipFromTop, .curveEaseInOut], animations: {
                self.emojiLabels[spot].superview!.alpha = 0
            }, completion: {
                void in

                // Completion block only needs to trigger once
                if spot == 0 {
                    if self.interstitial != nil {
                        self.startNextGame = true
                        self.shouldShowAd()
                    } else {
                        self.startNextGame = false
                        self.performNextLevelSetUp()
                    }
                }
            })
        }
    }
    
    func performNextLevelSetUp() {
        let packName = levelPackName.lowercased()
        
        if var _ = User.shared.completedLevels[packName] {
            // Completed levels for the level pack was not nil, add the level to completed levels for the pack
            User.shared.completedLevels[packName]!.append(levelNumber)
        } else {
            // No levels were completed for the pack, make this the first one
            User.shared.completedLevels[packName] = [levelNumber]
        }
        GameData.shared.defaults.set(User.shared.completedLevels, forKey: User.shared.completedLevelsKey)
        
        let nextLevel = determineNextLevel(fromLevel: levelNumber)
        if nextLevel > 0 {
            levelNumber = nextLevel
        } else {
            // No next level was found
            // Return to levels screen
            
            levelPackComplete()
            
            return
        }
        
        initializeKeys()
        fillFromDefaults()

        if let levels = GameData.shared.levels, let levelPack = levels[packName] {
            gameString = levelPack[levelNumber - 1]
            game = WordGame(gameString: gameString)
        } else {
            return
        }
        game.delegate = self
        UIView.transition(with: levelLabel, duration: 0.75, options: [.transitionCrossDissolve, .curveEaseInOut], animations: { self.setUpLevelName() }, completion: nil)
        game.startGame()
        game.fillCorrectAnswers(correctAnswerSpots)
        setUpClueArea()
        animateGameStart()
    }
    
    func levelPackComplete() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
            self.levelPackImage.transform = CGAffineTransform(scaleX: 1.0, y: 0.1)
        }, completion: {
            void in
            
            UIView.animate(withDuration: 0.2, animations: {
                self.levelPackImage.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                
            }, completion: {
                void in
                UIView.animate(withDuration: 0.75, animations: {
                    self.setUpGameOverView()

                    if let dimmer = self.dimmer {
                        dimmer.alpha = 0.8
                        self.gameOverView.alpha = 1.0
                    }
                })
            })
        })
    }
    
    func determineNextLevel(fromLevel level: Int) -> Int {
        var nextLevel = 0
        
        guard let levels = GameData.shared.levels, let levelPack = levels[levelPackName.lowercased()] else { return 0 }
        guard let completedLevels = User.shared.completedLevels[levelPackName.lowercased()] else { return 0 }
        
        // Get a lower level
        // Should be the lowest level not completed in pack
        for level in 1..<levelNumber {
            if !completedLevels.contains(level) {
                nextLevel = level
                break
            }
        }
        
        // Get an upper level
        // Should be lowest level after current level
        // If none exist, we'll be using the lower level as the next level
        for level in levelNumber...levelPack.count {
            if !completedLevels.contains(level) {
                nextLevel = level
                break
            }
        }
        
        return nextLevel
    }
    
    @IBAction func returnToLevelsTapped(_ sender: Any) {
        // Go back to the levels view
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Game Delegate extension
extension GameViewController: WordGameDelegate {
    func setClueInformation(emojis: String, hint: String, words: Int, answer: String) {
        if let popUp = popUp {
            popUp.emojisText = emojis
            popUp.hintText = hint
            popUp.wordsCount = words
            popUp.letterCount = answer.count
        }
    }
    
    func revealWord(at correctSpot: Int, word: String, shouldVibrate: Bool, revealedByHint: Bool) {
        wordCountLabels[correctSpot].text = word.uppercased()

        if shouldVibrate {
            // Only perform reveal animation/vibration when a guess occurs
            // Don't do it when loading correct answers as view appears
            animateWordReveal(atSpot: correctSpot)
            
            if !revealedByHint {
                setGemCount(toCount: User.shared.gemCount + 1)
                let notifier = UINotificationFeedbackGenerator()
                notifier.notificationOccurred(.success)
                AudioPlayer.shared.playSoundEffect(soundEffect: "correctAnswer", ext: "mp3")
            }
        }
        
        // Keep array from bloating
        // Ensures only one value of a correct spot is in the array
        correctAnswerSpots.append(correctSpot)
        correctAnswerSpots = Array(Set(correctAnswerSpots))
        GameData.shared.defaults.set(correctAnswerSpots, forKey: correctAnswerKey)
    }
    
    func animateGameStart() {
        modifyGuessButton(withModification: "disabled")
        animateClueAreaStart(withIndex: 0)
        animateCircleStart()
    }
    
    func animateCircleStart() {
        setUpTimer()
        spinCircles()
        for circle in circles {
            UIView.animate(withDuration: 0.75, delay: 0, options: [.curveEaseIn], animations: {
                UIView.animate(withDuration: 0.75, animations: {
                    circle.alpha = 1.0
                })
            }) { void in
                
            }
            
            for text in circle.labels {
                UIView.animate(withDuration: 1.5, animations: {
                    text.alpha = 1.0
                })
            }
        }
    }
    
    func animateClueAreaStart(withIndex index: Int) {
        if index == wordCountLabels.count {
            return
        }
        
        let label = wordCountLabels[index]
        
        UIView.transition(with: label.superview!, duration: 0.5, options: [.transitionFlipFromTop], animations: {
            label.superview!.alpha = 1.0
        }, completion: {
            void in
            AudioPlayer.shared.playSoundEffect(soundEffect: "clueFlip", ext: "wav")
            self.animateClueAreaStart(withIndex: index + 1)
        })
    }
    
    func animateWordReveal(atSpot spot: Int) {
        var transition: UIView.AnimationOptions
        let random = Int.random(in: 0...1)
        switch random {
        case 0:
            transition = .transitionFlipFromTop
        case 1:
            transition = .transitionFlipFromBottom
        default:
            transition = .transitionFlipFromTop
        }
        
        UIView.transition(with: wordCountLabels[spot], duration: 0.75, options: [transition, .curveEaseInOut], animations: {
            
        }, completion: {
            void in
            
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
                self.wordCountLabels[spot].transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }, completion: {
                void in
                UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseIn, animations: {
                    self.wordCountLabels[spot].transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: {
                    void in
                    
                    self.game.isGameOver()
                })
            })
            
        })
    }
    
    func setWheelLetter(wheels: [[String]]) {
        for i in 0..<wheels.count {
            var skippedOffset = 0
            for j in 0..<circles[i].labels.count {
                if circles[i].labels[j].isHidden {
                    skippedOffset += 1
                    continue
                } else {
                    circles[i].labels[j].alpha = 0
                    circles[i].labels[j].text = wheels[i][j - skippedOffset].uppercased()
                }
            }
        }
    }
    
    func setClues(clues: [EmojiClue]) {
        for i in 0..<clues.count {
            let emojis = clues[i].emojis!
            let letterCount = clues[i].answer.count
            let letterLabel = "\(letterCount) LETTERS"
            
            emojiLabels[i].text = emojis
            wordCountLabels[i].text = letterLabel
        }
    }
    
    func updateGuessText(withText text: String) {
        guessText.text = text.uppercased()
        
        if text == "" {
            modifyGuessButton(withModification: "disabled")
            
            for circle in circles {
                if isCircleSpinning(circle: circle) {
                    return
                }
            }
            
            modifyGuessButton(withModification: "spin")
        } else {
            modifyGuessButton(withModification: "guess")
        }
    }
    
    func incorrectGuess() {
        let notifier = UINotificationFeedbackGenerator()
        notifier.notificationOccurred(.error)
        AudioPlayer.shared.playSoundEffect(soundEffect: "incorrectAnswer", ext: "mp3")
    }

    func shouldShowAd() {
        showInterstitialAd()
    }
}

// MARK: - CAAnimation Delegate extension for wheel spin animation
extension GameViewController: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        for circle in circles {
            if isCircleSpinning(circle: circle) {
                return
            }
        }
        
        if let guessText = guessText.text {
            if guessText == "" {
                modifyGuessButton(withModification: "spin")
            } else {
                modifyGuessButton(withModification: "guess")
            }
        }
        
        if !User.shared.helpSeen {
            showHelpPrompt()
        }
        
        timer.invalidate()
    }
    
    func setUpTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {
            (void) in
            
            for circle in self.circles {
                circle.transform = (circle.layer.presentation()?.affineTransform())!
                circle.centerButton.transform = circle.transform.inverted()
                
                for label in circle.labels {
                    label.transform = circle.transform.inverted()
                }
                
                self.highlightSector(onCircle: circle)
            }
        }
        timer.fire()
    }
    
    func isCircleSpinning(circle: SegmentedCircleView) -> Bool {
        if circle.layer.animationKeys() != nil {
            return true
        }
        
        return false
    }
    
    func spinCircles() {
        for circle in circles {
            let randomAngle = getRandomSpinAngle(forCircle: circle)
            let randomSpinCount = Int.random(in: 6...10)
            let randomSpeed = Double.random(in: 3...5)
            spinAnimation(toAngle: randomAngle, onCircle: circle, spinCount: randomSpinCount, withSpeed: randomSpeed)
        }
    }
    
    func getRandomSpinAngle(forCircle circle: SegmentedCircleView) -> CGFloat {
        let random = Int.random(in: -circle.numOfSegments / 2...circle.numOfSegments / 2)
        
        if random == 0 {
            return 2 * CGFloat.pi
        }
        
        return (CGFloat(random) * CGFloat.pi) / (CGFloat(circle.numOfSegments) / 2.0)
    }
    
    func spinAnimation(toAngle angle: CGFloat, onCircle circle: SegmentedCircleView, spinCount: Int, withSpeed speed: Double) {
        // maybe do something like this? spin animation
        // make sure to conform to CABasicAnimationDelegate
        // add the animationdidstop function
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = angle
        rotateAnimation.toValue = CGFloat(2 * spinCount) * CGFloat.pi + angle
        rotateAnimation.duration = speed
        rotateAnimation.repeatCount = 0
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        rotateAnimation.delegate = self
        
        circle.layer.add(rotateAnimation, forKey: "rotating")
        
        let counterRotate = CABasicAnimation(keyPath: "transform.rotation")
        counterRotate.fromValue = CGFloat(2 * spinCount) * CGFloat.pi - angle
        counterRotate.toValue =  -angle
        counterRotate.duration = speed
        counterRotate.repeatCount = 0
        counterRotate.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        circle.movedDistance = angle
        
        for label in circle.labels {
            label.layer.add(counterRotate, forKey: nil)
        }
        
        circle.centerButton.layer.add(counterRotate, forKey: nil)
    }
}

// MARK: - Menu Delegate Extension
extension GameViewController: MenuDelegate {
    func homeButtonInteraction() {
        closeMenu(completion: {
            self.navigationController?.popToRootViewController(animated: true)
        })
    }
    
    func levelsButtonInteraction() {
        closeMenu(completion: {
            self.navigationController?.popViewController(animated: true)
        })
    }
        
    func soundInteraction() {
        User.shared.prefersSoundEffects = !User.shared.prefersSoundEffects
        GameData.shared.defaults.set(User.shared.prefersSoundEffects, forKey: User.shared.soundKey)
        
        if let menu = menu {
            menu.updateSoundLabel()
        }
    }
    
    func helpInteraction() {
        returningFromHelp = true
        performSegue(withIdentifier: "segueToHelp", sender: self)
    }
    
    func iapPurchaseTapped(ofCount count: Int) {
        var inAppPurchase: IAP
        
        switch count {
        case 100:
            inAppPurchase = IAP.OneHundredGems
        case 250:
            inAppPurchase = IAP.TwoFiftyGems
        case 750:
            inAppPurchase = IAP.SevenFiftyGems
        case 2000:
            inAppPurchase = IAP.TwoThousandGems
        case 5000:
            inAppPurchase = IAP.FiveThousandGems
        default:
            return
        }
        
        InAppPurchase.shared.purchaseProduct(product: inAppPurchase)
    }
}

// MARK: - Hint PopUp Delegate Extension
extension GameViewController: HintPopUpDelegate {
    func revealHintTapped() {
        if let popUp = popUp {
            if User.shared.gemCount < 10 {
                return
            }
            
            
            popUp.hintIsRevealed = true
            if !hintRevealed.contains(popUp.infoForClue) {
                hintRevealed.append(popUp.infoForClue)
                GameData.shared.defaults.set(hintRevealed, forKey: hintKey)
            }
            setGemCount(toCount: User.shared.gemCount - 10)
            
            UIView.animate(withDuration: 0.6) {
                popUp.blurView.alpha = 0.0
            }
        }
    }

    func playAdTapped() {
        showRewardedAd()
    }
    
    func revealWordTapped(atSpot spot: Int) {
        if let popUp = popUp {
            if User.shared.gemCount < 20 {
                return
            }
            
            popUp.wordIsRevealed = true
            if !correctAnswerSpots.contains(spot) {
                correctAnswerSpots.append(spot)
                GameData.shared.defaults.set(correctAnswerSpots, forKey: correctAnswerKey)
            }
            
            game.fillSingleAnswer(correctSpot: spot)
            setGemCount(toCount: User.shared.gemCount - 20)
            popUp.closeFrame()
        }
    }
    
    func closePopUp() {
        if let popUp = popUp {
            UIView.animate(withDuration: 0.25, animations: {
                popUp.alpha = 0
            }) {
                (void) in
                popUp.removeFromSuperview()
                self.popUp = nil
            }
        }
    }
}

// MARK: - InAppPurchase delegate
extension GameViewController: InAppPurchaseDelegate {
    func alertUser(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController
        
        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }
        
        topMostViewController?.present(alert, animated: true, completion: nil)
    }
        
    func levelPackPurchaseCompleted(restored: Bool, isGemPurchase: Bool) {
        // Implementation un-needed here
    }
    
    func redeemGemPurchase(gemCount: Int, restored: Bool) {
        setGemCount(toCount: User.shared.gemCount + gemCount)
        
        if !restored {
            User.shared.inAppPurchases?.append("\(gemCount)")
        }
    }
}

// MARK: - Interstitial Delegate
extension GameViewController: GADFullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }

    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
        returningFromAd = true
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        switch adType {
        case .interstitial:
            loadInterstitialAd()
        case .rewarded:
            loadRewardedAd()
        case .none:
            break
        }

        if startNextGame {
            startNextGame = false
            performNextLevelSetUp()
        }
    }
}
