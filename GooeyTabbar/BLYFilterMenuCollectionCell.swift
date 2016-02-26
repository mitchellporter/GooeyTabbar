//
//  BLYFilterMenuCollectionCell.swift
//  Blinky
//
//  Created by Mitchell Porter on 2/24/16.
//  Copyright © 2016 Mentor Ventures, Inc. All rights reserved.
//

import UIKit

class BLYFilterMenuCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    let TOPSPACE : CGFloat = 14.0 //留白
    var diff: CGFloat?
    
    override func drawRect(rect: CGRect) {
        
        print("cell drawRect")
        
        guard let diff = diff else {
            return
        }
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0)) // top left corner
        path.addLineToPoint(CGPoint(x: self.frame.width, y: 0)) // top right corner
        path.addLineToPoint(CGPoint(x: self.frame.width, y: self.frame.height - TOPSPACE))
        path.addQuadCurveToPoint(CGPoint(x: 0, y: self.frame.height - TOPSPACE), controlPoint: CGPoint(x: self.frame.width/2, y: self.frame.height - TOPSPACE-diff))
        path.closePath()
        
        let context = UIGraphicsGetCurrentContext()
        CGContextAddPath(context, path.CGPath)
        UIColor.greenColor().set()
        UIColor(red:0.863,  green:0.318,  blue:0.604, alpha:1).set() // Pink
        //        UIColor(red:0.945,  green:0.800,  blue:0.012, alpha:1).set() // Yellow
        CGContextFillPath(context)
    }
}


// Figure out the cell's top space value