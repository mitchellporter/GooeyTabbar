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
    
    let TOPSPACE : CGFloat = 75.375 //留白 // Increase the top space to decrease the height of the elastic effect at top of each cell
    var diff: CGFloat = 0.0
    var categoryColor: UIColor!
    
    override func drawRect(rect: CGRect) {
        
//        layer.borderWidth = 2
//        layer.borderColor = categoryColor.CGColor
        
        // Add border to top and bottom, but hide it on the sides
        label.transform = CGAffineTransformMakeTranslation(0, -diff/2.2)
        iconImageView.transform = CGAffineTransformMakeTranslation(0, -diff/2.2)
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0)) // top left corner
        path.addLineToPoint(CGPoint(x: self.frame.width, y: 0)) // top right corner
        path.addLineToPoint(CGPoint(x: self.frame.width, y: 0)) // Flat bottom line
        path.addQuadCurveToPoint(CGPoint(x: 0, y: self.frame.height - TOPSPACE), controlPoint: CGPoint(x: self.frame.width/2, y: self.frame.height - TOPSPACE-diff)) // You had to divide to reduce the number,
                                                                                                                                                                // otherwise it stretched to far and was cut off by the next cell
        path.closePath()
        
        let context = UIGraphicsGetCurrentContext()
        CGContextAddPath(context, path.CGPath)
        UIColor.greenColor().set()
        categoryColor.set()
//        UIColor(red:0.863,  green:0.318,  blue:0.604, alpha:1).set() // Pink
        //        UIColor(red:0.945,  green:0.800,  blue:0.012, alpha:1).set() // Yellow
        CGContextFillPath(context)
    }
}


// Figure out the cell's top space value