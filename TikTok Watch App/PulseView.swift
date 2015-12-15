//
//  PulseView.swift
//  TikTok
//
//  Created by Donald Chen on 12/14/15.
//  Copyright © 2015 MegaUkulele. All rights reserved.
//

import UIKit

class PulseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        UIColor.greenColor().setFill()
        path.fill()
        
//        // Get the Graphics Context
//        let context = UIGraphicsGetCurrentContext();
//        
//        // Set the circle outerline-width
//        CGContextSetLineWidth(context, 5.0);
//        
//        // Set the circle outerline-colour
//        UIColor.greenColor().set();
//        
//        // Create Circle
//        CGContextAddArc(context, (frame.size.width)/2, frame.size.height/2, (frame.size.width - 10)/2, 0.0, CGFloat(M_PI * 2.0), 1)
//        
//        // Draw
//        CGContextStrokePath(context);
    }
}
