//
//  TabbarMenu.swift
//  GooeyTabbar
//
//  Created by KittenYang on 11/16/15.
//  Copyright © 2015 KittenYang. All rights reserved.
//

import UIKit

protocol TabbarMenuDataSource {
    func numberOfFilterRows() -> Int
    func filterDataForRow(row: Int) -> [String: AnyObject]
}

protocol TabbarMenuDelegate {
    func didSelectFilterRow(indexPath: NSIndexPath)
}

class TabbarMenu: UIView{
    
    /// 是否打开
    var opened : Bool = false
    var collectionView: UICollectionView!
    var flowLayout = UICollectionViewFlowLayout()
    var dataSource: TabbarMenuDataSource!
    var delegate: TabbarMenuDelegate!
    
    var lastCell: BLYFilterMenuCollectionCell!

    private var normalRect : UIView!
    private var springRect : UIView!
    private var keyWindow  : UIWindow!
    private var blurView   : UIVisualEffectView!
    private var displayLink : CADisplayLink!
    private var animationCount : Int = 0
    private var diff : CGFloat = 0
    private var terminalFrame : CGRect?
    private var initialFrame : CGRect?
    private var animateButton : AnimatedButton?
    
    let TOPSPACE : CGFloat = 64.0 //留白
    private var tabbarheight : CGFloat? //tabbar高度
    
    var cells = [BLYFilterMenuCollectionCell]()
    
    init(tabbarHeight : CGFloat)
    {
        tabbarheight = tabbarHeight
        terminalFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        initialFrame = CGRect(x: 0, y: -UIScreen.mainScreen().bounds.height + tabbarHeight + TOPSPACE, width: terminalFrame!.width, height: terminalFrame!.height)
        // initial frame simply shows the tab bar height + top space on screen, everything else is hidden
        super.init(frame: initialFrame!)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func drawRect(rect: CGRect)
    {
        
        // HERE IS HOW THIS ENTIRE ANIMATION WORKS:
        // 1. We have 2 views, normalRect and springRect, they exist so that we can keep track of
        // the animation. normalRect is the normal one, but springRect is the one that helps drive the elastic effect.
        
        // 2. Right before we kick off the animation code, we start running the display link. The display link constantly
        // calls the update method.
        
        // In the update method, it just grabs the current values for the normal and spring rect views to
        // set our "diff value", and then it just calles setNeedsDisplay at the end.
        
        // 3. drawRect is called after setNeedsDisplay, and drawRect simply uses the "diff" value to calculate the arch.
        
        // SUMMARY: There are 3 key things happening here: drawRect, animation code, and the display link
        // 1. drawRect uses a tracked variable to draw the arch
        // 2. The animation code moves 2 tracker views
        // 3. The display link updates our tracked variable and calls setNeedsDisplay()
        //    which triggers step 1 again.
        
        
        // drawRect is called as the animation is happening. My guess is that it's called
        // every time setNeedsDisplay is called, which is in the display link's update method.
        
        // TODO: Fix 1px Line Problem
        // Right now the color of the menu is causing the 
        // 1px line to show in-between the cells
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0)) // top left corner
        path.addLineToPoint(CGPoint(x: self.frame.width, y: 0)) // top right corner
        path.addLineToPoint(CGPoint(x: self.frame.width, y: self.frame.height - TOPSPACE)) // Bottom of entire view, notice how instead of filling the whole view it leaves clear space for the TOPSPACE

        path.addQuadCurveToPoint(CGPoint(x: 0, y: self.frame.height - TOPSPACE), controlPoint: CGPoint(x: self.frame.width/2, y: self.frame.height - TOPSPACE-diff))
        path.closePath()
        
        let context = UIGraphicsGetCurrentContext()
        CGContextAddPath(context, path.CGPath)
        UIColor(red:0.863,  green:0.318,  blue:0.604, alpha:1).set() // Pink
//        UIColor(red:0.945,  green:0.800,  blue:0.012, alpha:1).set() // Yellow
        CGContextFillPath(context)
    }
    
    func setupCollectionView() {
        
        collectionView = UICollectionView(frame: CGRectMake(0, 0, bounds.size.width, self.frame.height - TOPSPACE), collectionViewLayout: flowLayout)
        collectionView.registerNib(UINib(nibName: "BLYFilterMenuCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Style
        collectionView.backgroundColor = UIColor.clearColor()
        flowLayout.minimumLineSpacing = 0.0
        flowLayout.minimumInteritemSpacing = 0.0
        
        collectionViewBackgroundHack()
    }
    
    func collectionViewBackgroundHack() {
//        let newView = UIView(frame: bounds)
//        let top = UIView(frame: CGRectMake(0, 0, bounds.size.width, bounds.size.height/2))
//        let bottom = UIView(frame: CGRectMake(0, bounds.size.height/2, bounds.size.width, newView.bounds.size.height/2))
//        
//        let topData = defaultFilterMenuData.first
//        top.backgroundColor = topData!["backgroundColor"] as? UIColor
//        
//        let bottomData = defaultFilterMenuData.last
//        bottom.backgroundColor = bottomData!["backgroundColor"] as? UIColor
//        
//        newView.addSubview(top)
//        newView.addSubview(bottom)
//        addSubview(newView)
//        
//        bringSubviewToFront(collectionView)
//        collectionView.backgroundColor = .clearColor()
        
//        var collectionViewFrame = collectionView.frame
//        collectionViewFrame.origin.y -= CGFloat(68)
//        collectionViewFrame.size.height += CGFloat(68)
//        collectionView.frame = collectionViewFrame
    }
    
    func setUpViews()
    {

        self.clipsToBounds = true
        self.layer.masksToBounds = true
        
        keyWindow = UIApplication.sharedApplication().keyWindow
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        blurView.frame = self.bounds
        blurView.alpha = 0.0
        keyWindow.addSubview(blurView)
        
        self.backgroundColor = UIColor.clearColor()
        keyWindow.addSubview(self)
        
        // Both rect views should be in the clear / top space area, closer to the color
        
        // BLUE
        normalRect = UIView(frame: CGRect(x: 0, y: tabbarheight! + 10, width: 30, height: 30))
        normalRect.backgroundColor = UIColor.blueColor()
        normalRect.hidden = false
        keyWindow.addSubview(normalRect)
        
        // YELLOW
        springRect = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.size.width/2 - 30/2, y: tabbarheight! + 10, width: 30, height: 30))
        springRect.backgroundColor = UIColor.yellowColor()
        springRect.hidden = false
        keyWindow.addSubview(springRect)
        
//        print(normalRect.center.y)
//        print(springRect.center.y)
//        
//        print(normalRect.frame.origin.y)
//        print(springRect.frame.origin.y)

        
        
        // Add the collection view
        self.addSubview(collectionView)

        
        // At bottom of entire view, then minus top space (clear),
        animateButton = AnimatedButton(frame: CGRect(x: 0, y: terminalFrame!.height - TOPSPACE - tabbarheight!, width: 50, height: 30))
        self.addSubview(animateButton!)
        animateButton!.didTapped = { (button) -> () in
            self.triggerAction()
        }
        
       
        }
    
    func spinIconsAnimation() {
        let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems()
        let sortedIndexPaths = visibleIndexPaths.sort {$0.row > $1.row}
        
        for visibleIndexPath in sortedIndexPaths {
            let cellAbove = self.collectionView.cellForItemAtIndexPath(visibleIndexPath) as! BLYFilterMenuCollectionCell
            cellAbove.iconImageView.layer.addAnimation(CAAnimation.animationForAdditionalButton(), forKey: nil)
        }
    }
    
    func triggerAction()
    {
        if animateButton!.animating {
            return
        }
        
        /**
        *  展开
        */
        if !opened {
            opened = true
            startAnimation()
            
            // 1. First animation moves the springRect view up by 40. This created the initial pull and arch.
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                self.springRect.center = CGPoint(x: self.springRect.center.x, y: self.springRect.center.y + 40)
                }) { (finish) -> Void in
                    
                    // START OF DROP DOWN ANIMATION
                    // This is the animation where entire view drops
                    // Time collision animation / effects on icons with this one
                    UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                        self.frame = self.terminalFrame!
                        }, completion: { (finish) -> Void in
                    })

                    
                    // END OF DROP DOWN ANIMATION
                    
                    UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: { () -> Void in
                        self.normalRect.center = CGPoint(x: self.normalRect.center.x, y: 567.0)
                        self.blurView.alpha = 1.0
                        }, completion: nil)
                    
                    UIView.animateWithDuration(1.0, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                        self.springRect.center = CGPoint(x: self.springRect.center.x, y: 567.0)
                        }, completion: { (finish) -> Void in
                            self.finishAnimation()
                    })
            }
        }else{
            /**
            *  收缩
            */
            opened = false
            startAnimation()
            
            
            // START OF BACK UP ANIMATION
            // This is the animation where entire view goes back up
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                self.frame = self.initialFrame!
                }, completion: nil)
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                self.normalRect.center = CGPoint(x: self.normalRect.center.x, y: 50.0)
                self.blurView.alpha = 0.0
                }, completion: nil)
            
            // inward, outward, normal
            UIView.animateWithDuration(0.2, delay:0.0, options: .CurveEaseOut, animations: { () -> Void in
                self.springRect.center = CGPoint(x: self.springRect.center.x, y: 20.0) // Inward
                }, completion: { (finish) -> Void in
                    UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                        self.springRect.center = CGPoint(x: self.springRect.center.x, y: 60.0) // Outward
                        }, completion: { (finish) -> Void in
                            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                                self.springRect.center = CGPoint(x: self.springRect.center.x, y: 50.0) // Normal
                                }, completion: { (finish) -> Void in
                                    self.finishAnimation()
                            })
                    })
            })
        }
    }
    
    
    @objc private func update(displayLink: CADisplayLink)
    {
        let normalRectLayer = normalRect.layer.presentationLayer()
        let springRectLayer = springRect.layer.presentationLayer()
        
        let normalRectFrame = normalRectLayer!.valueForKey("frame")!.CGRectValue
        let springRectFrame = springRectLayer!.valueForKey("frame")!.CGRectValue
        
        
        for cell in cells {
            cell.diff = diff
            cell.setNeedsDisplay()
        }
        diff = normalRectFrame.origin.y - springRectFrame.origin.y
        
//        print("=====\(diff)")
        self.setNeedsDisplay()
    }
    
    private func startAnimation()
    {
        if displayLink == nil
        {
            self.displayLink = CADisplayLink(target: self, selector: "update:")
            self.displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        }
        animationCount++
    }
    
    private func finishAnimation()
    {
        
//        print(springRect.center.y)
        
        animationCount--
        if animationCount == 0
        {
            displayLink.invalidate()
            displayLink = nil
        }
    }
}

extension TabbarMenu: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        // To make cells fit perfectly, we take the height of the filled path color of the menu
        // which is frame height - TOPSPACE, and divide it by total # of cells (8) eg. iPhone 6 size: 75.375
        // (self.frame.height - TOPSPACE) / 8)
        return CGSizeMake(collectionView.frame.size.width, (self.frame.height - TOPSPACE) / 8)
    }
}

extension TabbarMenu: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.numberOfFilterRows()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let filterData = dataSource.filterDataForRow(indexPath.row)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! BLYFilterMenuCollectionCell
        
        cell.clipsToBounds = true
        cell.layer.masksToBounds = true
        cell.contentView.clipsToBounds = true
        cell.contentView.layer.masksToBounds = true
        
        cell.iconImageView.clipsToBounds = true
        cell.iconImageView.layer.masksToBounds = true

        
        cell.iconImageView.image = UIImage(named: filterData["imageName"] as! String)
        
        cell.iconImageView.clipsToBounds = true
        cell.iconImageView.layer.masksToBounds = true
        
        cell.label!.text = filterData["name"] as? String

        
        if indexPath.row == 7 {
            cell.backgroundColor = UIColor.clearColor()
        } else {
//            cell.backgroundColor = UIColor.greenColor() // TESTING
            cell.backgroundColor = filterData["backgroundColor"] as? UIColor
        }
        
        if indexPath.row != 0 {
            let previousFilterData = dataSource.filterDataForRow(indexPath.row-1)
            cell.categoryColor = previousFilterData["backgroundColor"] as? UIColor
        } else {
            cell.categoryColor = filterData["backgroundColor"] as? UIColor
        }
        
        cells.append(cell)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        delegate.didSelectFilterRow(indexPath)
        
//         Part 1 - Play with cell z-index + cell movements
//                let selectedCell = collectionView.cellForItemAtIndexPath(indexPath)
//                selectedCell?.layer.zPosition = 10.0
//        
//                let visibleCells = collectionView.visibleCells
//                let visibleIndexPaths = collectionView.indexPathsForVisibleItems()
//        
//                for visibleIndexPath in visibleIndexPaths {
//                    if visibleIndexPath.row < indexPath.row {
//                        print("cell above selected cell")
//                        let cellAbove = collectionView.cellForItemAtIndexPath(visibleIndexPath)
//                        UIView.animateWithDuration(2.0, animations: { () -> Void in
//                            selectedCell?.frame = cellAbove!.frame
//                        })
//                    }
//                }
        
        // Part 2 - move selected cell underneath the top cell
        //        let firstCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 1))
        //        let firstCell = collectionView.cellForItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 1))
        
        
        // PART 1: Animate all cells into the first cell
//        let selectedCell = collectionView.cellForItemAtIndexPath(indexPath) as! BLYFilterMenuCollectionCell
//        let visibleIndexPaths = collectionView.indexPathsForVisibleItems()
//        
//        let sortedIndexPaths = visibleIndexPaths.sort {$0.row < $1.row}
//        let firstCell = collectionView.cellForItemAtIndexPath(sortedIndexPaths.first!) as! BLYFilterMenuCollectionCell
//        firstCell.layer.zPosition = 10.0
//        
//        for visibleIndexPath in sortedIndexPaths {
//            // Skip the first cell for testing
//            if visibleIndexPath.row == 0 {
//                continue
//            }
//            
//            let cellAbove = collectionView.cellForItemAtIndexPath(visibleIndexPath)
//            UIView.animateWithDuration(0.2, animations: { () -> Void in
//                cellAbove!.frame = firstCell.frame
//            })
//        }
        
        // PART 2: First cell needs it's background color, label, and image icon set to match selected cell
        // A. Shape layer will explode new color into first cell. See here: https://github.com/Ramotion/paper-switch
        // B. Icon image view will spin from the shape layer explosion
        // C. Look into using some type of explosion / fireworks / CAReplicatorLayer?
        // so that you can have an "explosion effect from the new selected cell snapping into place"
        
//        firstCell.label.text = selectedCell.label.text
//        firstCell.iconImageView.image = selectedCell.iconImageView.image
//        firstCell.iconImageView.layer.addAnimation(CAAnimation.animationForAdditionalButton(), forKey: nil)
//        firstCell.backgroundColor = selectedCell.backgroundColor
        
    }
}


