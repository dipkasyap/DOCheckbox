//
//  DOCheckbox.swift
//  DOCheckbox
//
//  Created by Daiki Okumura on 2015/05/16.
//  Copyright (c) 2015 Daiki Okumura. All rights reserved.
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

import UIKit
// FIXME: comparison with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


enum DOCheckboxStyle : Int {
    case `default`
    case square
    case filledSquare
    case roundedSquare
    case filledRoundedSquare
    case circle
    case filledCircle
}

class DOCheckbox: UIButton {
    
    fileprivate var style: DOCheckboxStyle! = .default
    fileprivate var baseColor: UIColor = UIColor.black
    
    var checkboxFrame: CGRect! {
        didSet {
            // reset checkbox
            let ratioW = checkboxFrame.width / 100.0
            let ratioH = checkboxFrame.height / 100.0
            ratio = (ratioW > ratioH) ? ratioH : ratioW
            let checkboxSize: CGFloat = (ratioW > ratioH) ? checkboxFrame.height : checkboxFrame.width
            
            checkboxFrame = CGRect(x: checkboxFrame.origin.x, y: checkboxFrame.origin.y, width: checkboxSize, height: checkboxSize)
            checkboxLayer.frame = checkboxFrame
            
            checkLayer.frame = checkboxFrame
            checkBgLayer.frame = checkboxFrame
            
            // default setting
            setPresetStyle(style, baseColor: baseColor)
        }
    }
    var checkboxBorderWidth: CGFloat! = 0.0 {
        didSet {
            checkboxLayer.borderWidth = checkboxBorderWidth
            let rectCornerRadius = (checkboxCornerRadius > checkboxBorderWidth / 2) ? checkboxCornerRadius - checkboxBorderWidth / 2 : 0
            checkboxLayer.path = CGPath(roundedRect: CGRect(x: checkboxBorderWidth / 2, y: checkboxBorderWidth / 2, width: checkboxFrame.width - checkboxBorderWidth, height: checkboxFrame.height - checkboxBorderWidth), cornerWidth: rectCornerRadius, cornerHeight: rectCornerRadius, transform: nil)
        }
    }
    var checkboxCornerRadius: CGFloat! = 0.0 {
        didSet {
            checkboxLayer.cornerRadius = checkboxCornerRadius
            let rectCornerRadius = (checkboxCornerRadius > checkboxBorderWidth / 2) ? checkboxCornerRadius - checkboxBorderWidth / 2 : 0
            checkboxLayer.path = CGPath(roundedRect: CGRect(x: checkboxBorderWidth / 2, y: checkboxBorderWidth / 2, width: checkboxFrame.width - checkboxBorderWidth, height: checkboxFrame.height - checkboxBorderWidth), cornerWidth: rectCornerRadius, cornerHeight: rectCornerRadius, transform: nil)
        }
    }
    var checkWidth: CGFloat! {
        didSet {
            checkLayer.lineWidth = checkWidth
            checkLayer.miterLimit = checkWidth
            checkBgLayer.lineWidth = checkWidth
            checkBgLayer.miterLimit = checkWidth
        }
    }
    var checkboxBgColor: UIColor! {
        didSet { checkboxLayer.fillColor = checkboxBgColor.cgColor }
    }
    var checkboxBorderColor: UIColor! {
        didSet { checkboxLayer.borderColor = checkboxBorderColor.cgColor }
    }
    var checkColor: UIColor! {
        didSet { checkLayer.strokeColor = checkColor.cgColor }
    }
    var checkBgColor: UIColor! {
        didSet { checkBgLayer.strokeColor = checkBgColor.cgColor }
    }
    
    fileprivate(set) var ratio: CGFloat = 1.0
    let checkboxLayer: CAShapeLayer! = CAShapeLayer()
    let checkLayer: CAShapeLayer! = CAShapeLayer()
    let checkBgLayer: CAShapeLayer! = CAShapeLayer()
    
    override var isSelected: Bool {
        didSet {
            if (isSelected != oldValue) {
                let strokeStart = CABasicAnimation(keyPath: "strokeStart")
                let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
                if self.isSelected {
                    // check animation
                    strokeStart.fromValue = 0.0
                    strokeStart.toValue = 0.0
                    strokeStart.duration = 0.1
                    strokeEnd.fromValue = 0.0
                    strokeEnd.toValue = 1.0
                    strokeEnd.duration = 0.1
                } else {
                    // uncheck animation
                    strokeStart.fromValue = 0.0
                    strokeStart.toValue = 1.0
                    strokeStart.duration = 0.1
                    strokeEnd.fromValue = 1.0
                    strokeEnd.toValue = 1.0
                    strokeEnd.duration = 0.1
                    strokeEnd.fillMode = kCAFillModeBackwards
                }
                self.checkLayer.ocb_applyAnimation(strokeStart)
                self.checkLayer.ocb_applyAnimation(strokeEnd)
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout(frame, checkboxFrame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
    }
    
    init(frame: CGRect, checkboxFrame: CGRect) {
        super.init(frame: frame)
        layout(frame, checkboxFrame: checkboxFrame)
    }
    
    func layout(_ frame: CGRect, checkboxFrame: CGRect) {
        
        // checkbox
        self.checkboxFrame = checkboxFrame
        checkboxLayer.masksToBounds = true
        self.layer.addSublayer(checkboxLayer)
        
        // background check
        checkBgLayer.fillColor = nil
        checkBgLayer.masksToBounds = true
        checkBgLayer.strokeStart = 0.0
        checkBgLayer.strokeEnd = 1.0
        self.layer.addSublayer(checkBgLayer)
        
        // check
        checkLayer.fillColor = nil
        checkLayer.masksToBounds = true
        checkLayer.actions = ["strokeStart": NSNull(), "strokeEnd": NSNull()]
        checkLayer.strokeStart = 0.0
        checkLayer.strokeEnd = 0.0
        self.layer.addSublayer(checkLayer)
        
        // add target for TouchUpInside event
        self.addTarget(self, action: #selector(DOCheckbox.toggleSelected(_:)), for:.touchUpInside)
    }
    
    func toggleSelected(_ sender: AnyObject) {
        self.isSelected = !self.isSelected
    }
    
    func setPresetStyle(_ style: DOCheckboxStyle?, baseColor: UIColor?) {
        if (style != nil) {
            self.style = style!
        }
        if (baseColor != nil) {
            self.baseColor = baseColor!
        }
        
        // checkbox style
        switch (self.style!) {
        case .default:
            checkboxBorderWidth = 0
            checkboxCornerRadius = 0
            
        case .square, .filledSquare:
            checkboxBorderWidth = round(5 * ratio * 10) / 10
            checkboxCornerRadius = 0
            
        case .roundedSquare, .filledRoundedSquare:
            checkboxBorderWidth = round(5 * ratio * 10) / 10
            checkboxCornerRadius = round(15 * ratio * 10) / 10
            
        case .circle, .filledCircle:
            checkboxBorderWidth = round(5 * ratio * 10) / 10
            checkboxCornerRadius = round(50 * ratio * 10) / 10
        }
        
        // check style
        switch (self.style!) {
        case .default, .square, .filledSquare, .roundedSquare, .filledRoundedSquare, .circle, .filledCircle:
            checkWidth = round(15 * ratio * 10) / 10
            checkBgLayer.path = {
                let path = CGMutablePath()
                
                path.move(to: CGPoint(x: 27 * self.ratio, y: 53 * self.ratio))
                path.addLine(to: CGPoint(x: 42 * self.ratio, y: 68 * self.ratio))
                path.addLine(to: CGPoint(x: 75 * self.ratio, y: 34 * self.ratio))
                
                
                return path
            }()
            checkBgLayer.lineCap = kCALineCapSquare
            checkBgLayer.lineJoin = kCALineJoinMiter
            checkLayer.path = {
                let path = CGMutablePath()
                
                path.move(to: CGPoint(x: 27 * self.ratio, y: 53 * self.ratio))
                path.addLine(to: CGPoint(x: 42 * self.ratio, y: 68 * self.ratio))
                path.addLine(to: CGPoint(x: 75 * self.ratio, y: 34 * self.ratio))
                
                return path
            }()
            checkLayer.lineCap = kCALineCapSquare
            checkLayer.lineJoin = kCALineJoinMiter
        }
        
        // color
        switch (self.style!) {
        case .default, .square, .roundedSquare, .circle:
            checkboxBgColor = UIColor.white
            checkboxBorderColor = self.baseColor
            checkColor = self.baseColor
            checkBgColor = convertColor(self.baseColor, toColor: UIColor.white, percent: 0.85)
            
        case .filledSquare, .filledRoundedSquare, .filledCircle:
            checkboxBgColor = self.baseColor
            checkboxBorderColor = self.baseColor
            checkColor = UIColor.white
            checkBgColor = convertColor(self.baseColor, toColor: UIColor.white, percent: 0.3)
        }
    }
    
    func convertColor(_ fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var r1: CGFloat = 0.0
        var g1: CGFloat = 0.0
        var b1: CGFloat = 0.0
        var a1: CGFloat = 0.0
        fromColor.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        
        var r2: CGFloat = 0.0
        var g2: CGFloat = 0.0
        var b2: CGFloat = 0.0
        var a2: CGFloat = 0.0
        toColor.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let r: CGFloat = r1 + (r2 - r1) * percent
        let g: CGFloat = g1 + (g2 - g1) * percent
        let b: CGFloat = b1 + (b2 - b1) * percent
        let a: CGFloat = a1 + (a2 - a1) * percent
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension CALayer {
    func ocb_applyAnimation(_ animation: CABasicAnimation) {
        let copy = animation.copy() as! CABasicAnimation
        
        if copy.fromValue == nil {
            copy.fromValue = self.presentation()?.value(forKeyPath: copy.keyPath!)
        }
        
        self.add(copy, forKey: copy.keyPath)
        self.setValue(copy.toValue, forKeyPath:copy.keyPath!)
    }
}
