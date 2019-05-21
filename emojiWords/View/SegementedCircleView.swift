//
//  SegementedCircleView.swift
//  emojiWords
//
//  Created by Tyler Stickler on 3/21/19.
//  Copyright © 2019 Tyler Stickler. All rights reserved.
//

import UIKit

class SegmentedCircleView: UIView {
    // Variables that need to be accessed by the controller
    var numOfSegments: Int = 3
    var oldAngle: CGFloat = 0
    var movedDistance: CGFloat = 0
    var centerButton: UIButton!
    var currentSector = 0
    var labels = [UILabel]()
    
    private var lineWidth: CGFloat = 3
    private var strokeColor: UIColor = .black
    private var circleColor: CGColor!
    private var highlightColor: CGColor = UIColor.init(red: 3/255,
                                                       green: 192/255,
                                                       blue: 60/255,
                                                       alpha: 1.0).cgColor
    private var gapSize: CGFloat = 0.01
    var shapeLayers = [CAShapeLayer]()
    private var shapeIsDrawn = false
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if shapeIsDrawn {
            // Prevent shape from being redrawn when returning from background
            return
        }
        
        addLabels()
        addCenterButton()
        addIndicatorTriangle()
        
        let segmentAngleSize: CGFloat = (2 * .pi - CGFloat(numOfSegments) * gapSize) / CGFloat(numOfSegments)
        let center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        
        for i in 0..<numOfSegments {
            // properly set the starting rotation angle
            // for 3 it should be - (.pi / 2)
            // for 4 it should be - (.pi)
            // for 6 it should be - (2 * .pi)
            var startRotate: CGFloat = 0
            switch numOfSegments {
            case 3:
                startRotate = .pi / 2
            case 4:
                startRotate = .pi
            case 5:
                startRotate = 3 * .pi / 2
            case 6:
                startRotate =  2 * .pi
            default:
                startRotate = 0
            }
            
            let start = CGFloat(i) * (segmentAngleSize + gapSize) - (startRotate) / CGFloat(numOfSegments)
            let end = start + segmentAngleSize
            let segmentPath = UIBezierPath(arcCenter: center, radius: self.frame.width / 2 - lineWidth / 2, startAngle: start, endAngle: end, clockwise: true)
            segmentPath.addLine(to: center)
            segmentPath.close()
            
            let arcLayer = CAShapeLayer()
            arcLayer.path = segmentPath.cgPath
            arcLayer.fillColor = circleColor
            
            if i == numOfSegments - 1 {
                arcLayer.fillColor = highlightColor
            }
            
            arcLayer.strokeColor = strokeColor.cgColor
            arcLayer.lineWidth = lineWidth
            
            shapeLayers.append(arcLayer)
            layer.addSublayer(arcLayer)
        }
        
        currentSector = numOfSegments - 1
        shapeIsDrawn = true
    }
    
    private func addLabels() {
        for _ in 0...11 {
            let label = UILabel()
            let labelFontSize = self.frame.width / 7
            
            self.addSubview(label)
            labels.append(label)
            
            label.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
            label.textAlignment = .center
            label.font = UIFont.init(name: "VTC-GarageSale", size: labelFontSize)
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.textColor = .white
            label.layer.zPosition = 1
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        switch numOfSegments {
        case 3:
            for i in 0..<labels.count {
                if i != 2 && i != 4 && i != 7 {
                    labels[i].isHidden = true
                }
            }
        case 4:
            for i in 0..<labels.count {
                if i != 2 && i != 5 && i != 8 && i != 11 {
                    labels[i].isHidden = true
                }
            }
        case 5:
            for i in 0..<labels.count {
                if i != 1 && i != 4 && i != 6 && i != 9 && i != 11 {
                    labels[i].isHidden = true
                }
            }
        case 6:
            for i in 0..<labels.count {
                if i != 0 && i != 3 && i != 5 && i != 7 && i != 10 && i != 11 {
                    labels[i].isHidden = true
                }
            }
        default:
            break
        }
        
        var constraints = [NSLayoutConstraint]()
        let eightConstant = self.frame.width / 18.75
        let tenConstant = self.frame.width / 15.625
        let twelveConstant = self.frame.width / 12.5
        let twentyConstant = self.frame.width / 6
        let fortyConstant = self.frame.width / 3.75
        let fortyFourConstant = self.frame.width / 3
        
        constraints.append(NSLayoutConstraint(item: labels[0],
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: fortyConstant))
        constraints.append(NSLayoutConstraint(item: labels[0],
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: -twelveConstant))
        
        constraints.append(NSLayoutConstraint(item: labels[1],
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: fortyFourConstant))
        constraints.append(NSLayoutConstraint(item: labels[1],
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: -tenConstant))

        
        constraints.append(NSLayoutConstraint(item: labels[2],
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: labels[2],
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: -eightConstant))
        
        constraints.append(NSLayoutConstraint(item: labels[3],
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -fortyConstant))
        constraints.append(NSLayoutConstraint(item: labels[3],
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: -twelveConstant))
        
        constraints.append(NSLayoutConstraint(item: labels[4],
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -twentyConstant))
        constraints.append(NSLayoutConstraint(item: labels[4],
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .trailing,
                                              multiplier: 1.0,
                                              constant: -twentyConstant))

        
        constraints.append(NSLayoutConstraint(item: labels[5],
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -twelveConstant))
        constraints.append(NSLayoutConstraint(item: labels[5],
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        
        constraints.append(NSLayoutConstraint(item: labels[6],
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -twentyConstant))
        constraints.append(NSLayoutConstraint(item: labels[6],
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: twentyConstant))
        
        constraints.append(NSLayoutConstraint(item: labels[7],
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .bottom,
                                              multiplier: 1.0,
                                              constant: -fortyConstant))
        constraints.append(NSLayoutConstraint(item: labels[7],
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: twelveConstant))
        
        constraints.append(NSLayoutConstraint(item: labels[8],
                                              attribute: .centerY,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerY,
                                              multiplier: 1.0,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: labels[8],
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: eightConstant))
        
        
        constraints.append(NSLayoutConstraint(item: labels[9],
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: fortyFourConstant))
        constraints.append(NSLayoutConstraint(item: labels[9],
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: tenConstant))
        
        constraints.append(NSLayoutConstraint(item: labels[10],
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: fortyConstant))
        constraints.append(NSLayoutConstraint(item: labels[10],
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .leading,
                                              multiplier: 1.0,
                                              constant: twelveConstant))

        
        constraints.append(NSLayoutConstraint(item: labels[11],
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .top,
                                              multiplier: 1.0,
                                              constant: twelveConstant))
        constraints.append(NSLayoutConstraint(item: labels[11],
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: self,
                                              attribute: .centerX,
                                              multiplier: 1.0,
                                              constant: 0))
        

        
        for label in labels {
            constraints.append(NSLayoutConstraint(item: label,
                                                  attribute: .width,
                                                  relatedBy: .equal,
                                                  toItem: nil,
                                                  attribute: .width,
                                                  multiplier: 1.0,
                                                  constant: fortyConstant))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func addCenterButton() {
        let circleFrameWidth = self.frame.width
        centerButton = UIButton(type: .system)
        centerButton.frame = CGRect(x: circleFrameWidth / 3,
                                    y: circleFrameWidth / 3,
                                    width: circleFrameWidth / 3,
                                    height: circleFrameWidth / 3)
        let fontSize = circleFrameWidth / 3.75
        
        self.addSubview(centerButton)
        
        centerButton.layer.cornerRadius = centerButton.frame.width / 2
        centerButton.layer.borderWidth = 3
        centerButton.layer.borderColor = UIColor.black.cgColor
        centerButton.backgroundColor = .white
        centerButton.isEnabled = true
        centerButton.titleLabel?.font = UIFont.init(name: "VTC-GarageSale", size: fontSize)
        centerButton.setTitle("+", for: .normal)
        centerButton.setTitleColor(.black, for: .normal)
        centerButton.layer.zPosition = 1.0
    }
    
    private func addIndicatorTriangle() {
        let trianglePath = UIBezierPath()
        trianglePath.move(to: CGPoint(x: 0, y: -1))
        trianglePath.addLine(to: CGPoint(x: 30, y: -1))
        trianglePath.addLine(to: CGPoint(x: 15, y: 12))
        trianglePath.close()
        
        let triangle = CAShapeLayer()
        triangle.path = trianglePath.cgPath
        triangle.anchorPoint = .zero
        triangle.strokeColor = UIColor.black.cgColor
        triangle.fillColor = UIColor.yellow.cgColor
        triangle.position = CGPoint(x: self.frame.midX - 15, y: self.frame.minY)
        triangle.zPosition = 0.99
        triangle.lineWidth = 2.0
        
        self.superview!.layer.addSublayer(triangle)
    }
    
    func setCircleColor(withColor color: CGColor) {
        circleColor = color
    }
    
    func shouldHighlightSector(shouldHighlight: Bool, sector: Int) {
        if shouldHighlight {
            shapeLayers[sector].fillColor = highlightColor
        } else {
            shapeLayers[sector].fillColor = circleColor
        }
    }
}
