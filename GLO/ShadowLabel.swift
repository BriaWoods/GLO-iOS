//
//  ShadowLabel.swift
//  GLO
//
//  Created by Stephen Looney on 8/11/16.
//  Copyright © 2016 SpaceBoat Development LLC. All rights reserved.
//

import UIKit

class ShadowLabel: UILabel {

    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    /*
    override func drawRect(rect: CGRect) {
        // Drawing code
        let shadowOffset = CGSizeMake(0.0, 4.0)
        let shadowRadius:CGFloat = 8.0
        let context = UIGraphicsGetCurrentContext()
        
        
        CGContextSetShadowWithColor(context, shadowOffset, shadowRadius, UIColor.whiteColor().CGColor);
        
    }
    */
 
    override func drawTextInRect(rect: CGRect) {
        
        let shadowOffset = CGSizeMake(0.0, -1.5)
        let shadowRadius:CGFloat = 3.5
        let context = UIGraphicsGetCurrentContext()
        
        
        CGContextSetShadowWithColor(context, shadowOffset, shadowRadius, UIColor.whiteColor().CGColor);
        
        super.drawTextInRect(rect)
    }
    
    
}

