//
//  BLYFloatingLayout.swift
//  GooeyTabbar
//
//  Created by Mitchell Porter on 2/25/16.
//  Copyright © 2016 KittenYang. All rights reserved.
//

import UIKit

class BLYFloatingLayout: UICollectionViewFlowLayout {
    
        override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
            return true
        }
        
        override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
            guard let layoutAttributes = super.layoutAttributesForElementsInRect(rect) else { return nil }
            var attributesArray = layoutAttributes.map { $0.copy() } as! [UICollectionViewLayoutAttributes]
            
            let contentOffset = collectionView?.contentOffset ?? CGPointZero
            
            let missingRowAttributesArray = missingRowsAttributes(attributesArray)
            attributesArray += missingRowAttributesArray
            
            attributesArray.forEach { attributes in
                if attributes.representedElementCategory == .Cell {
                    if attributes.indexPath.item  == 0 {
//                        attributes.frame.origin.y = contentOffset.y
                        attributes.zIndex = 10
                    } else {
                        
                    }
                }
            }
            
            return attributesArray
        }
        
        private func missingRowsAttributes(attributesArray: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes] {
            var array: [UICollectionViewLayoutAttributes] = []
            var missingRows: Set<Int> = [0]
            
            attributesArray.forEach { attributes in
                if attributes.representedElementCategory == .Cell {
                    missingRows.remove(attributes.indexPath.item)
                }
            }
            
            missingRows.forEach { missingRow in
                let indexPath = NSIndexPath(forItem: missingRow, inSection: 0)
                let attributes = layoutAttributesForItemAtIndexPath(indexPath)
                
                if let attributes = attributes {
                    array.append(attributes.copy() as! UICollectionViewLayoutAttributes)  
                }  
            }  
            
            return array  
        }  
    

}
