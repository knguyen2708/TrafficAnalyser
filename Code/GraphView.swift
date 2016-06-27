//
//  GraphView.swift
//  Traffic_Eric
//
//  Created by Khanh Nguyen on 27/06/2016.
//  Copyright © 2016 knguyen. All rights reserved.
//

import UIKit
import CoreGraphics

class GraphView: UIView {
    
    var vehicles: [Vehicle] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var timeWindow: Double = (1.0 * 3600 * 1000) { // 1 hour
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var frame: CGRect {
        get { return super.frame }
        set {
            super.frame = newValue
            setNeedsDisplay()
        }
    }
    
    override var bounds: CGRect {
        get { return super.bounds }
        set {
            super.bounds = newValue
            setNeedsDisplay()
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if vehicles.count < 2 { return }
        
        let insets = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 10)
        let w = frame.width - insets.left - insets.right
        let h = frame.height - insets.top - insets.bottom
        
        let minDay = vehicles.map { $0.day }.minElement()!
        let maxDay = vehicles.map { $0.day }.maxElement()!
        
        var counts: [Int] = []
        let countPerDay = 24 * 3600 * 1000 / timeWindow
        
        for day in minDay...maxDay {
            var t: Double = 0
            while t < 24 * 3600 * 1000 {
                let t1 = t + timeWindow
                
                let count = self.vehicles.filter { $0.day == day && t <= $0.time && $0.time < t1 }.count
                counts.append(count)
                
                t = t1
            }
        }
        
        let maxCount = counts.maxElement()!
        
        let ctx = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
        CGContextFillRect(ctx, bounds)
        
        let dx = w / CGFloat(counts.count)
        
        for (i, count) in counts.enumerate() {
            let x = insets.left + CGFloat(i) * dx
            let y = insets.top + h * CGFloat(maxCount - count) / CGFloat(maxCount)
            
            let day = floor(Double(i) / Double(countPerDay))
            let color = day % 2 == 0 ? UIColor.redColor() : UIColor.blueColor()

            CGContextSetFillColorWithColor(ctx, color.CGColor)

            CGContextFillRect(ctx, CGRect(
                x: x,
                y: y,
                width: dx - 1, // Some variation
                height: frame.height - y - insets.bottom
            ))
        }
        
    }

}
