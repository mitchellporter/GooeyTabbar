//
//  TabbarMenu.swift
//  GooeyTabbar
//
//  Created by KittenYang on 11/16/15.
//  Copyright © 2015 KittenYang. All rights reserved.
//

import UIKit

class TabbarMenu: UIView{
    
    /// 是否打开
    var opened : Bool = false
    
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
    
    init(tabbarHeight : CGFloat)
    {
        tabbarheight = tabbarHeight
        terminalFrame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: UIScreen.mainScreen().bounds.size.height)
        initialFrame = CGRect(x: 0, y: 0 - terminalFrame!.height + tabbarHeight + TOPSPACE, width: terminalFrame!.width, height: terminalFrame!.height)
        super.init(frame: initialFrame!)
        setUpViews()
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
        
        
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: 0, y: 0)) // Bottom left corner
        path.addLineToPoint(CGPoint(x: self.frame.width, y: 0)) // Bottom right corner
        path.addLineToPoint(CGPoint(x: self.frame.width, y: self.frame.height - TOPSPACE))
        path.addQuadCurveToPoint(CGPoint(x: 0, y: self.frame.height - TOPSPACE), controlPoint: CGPoint(x: self.frame.width/2, y: self.frame.height - TOPSPACE-diff))
        path.closePath()
        
        let context = UIGraphicsGetCurrentContext()
        CGContextAddPath(context, path.CGPath)
        UIColor(colorLiteralRed: 50/255.0, green: 58/255.0, blue: 68/255.0, alpha: 1.0).set()
        CGContextFillPath(context)
    }
    
    
    private func setUpViews()
    {
        keyWindow = UIApplication.sharedApplication().keyWindow
        
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        blurView.frame = self.bounds
        blurView.alpha = 0.0
        keyWindow.addSubview(blurView)
        
        self.backgroundColor = UIColor.clearColor()
        keyWindow.addSubview(self)
        
        // What are these different views for???
        
        // BLUE
        normalRect = UIView(frame: CGRect(x: 0, y: (self.frame.origin.y + self.frame.height) - (30 + 10), width: 30, height: 30))
        normalRect.backgroundColor = UIColor.blueColor()
        normalRect.hidden = false
        keyWindow.addSubview(normalRect)
        
        // YELLOW
        springRect = UIView(frame: CGRect(x: UIScreen.mainScreen().bounds.size.width/2 - 30/2, y: normalRect.frame.origin.y, width: 30, height: 30))
        springRect.backgroundColor = UIColor.yellowColor()
        springRect.hidden = false
        keyWindow.addSubview(springRect)
        
        
        // At bottom of entire view, then minus top space (clear),
        animateButton = AnimatedButton(frame: CGRect(x: 0, y: terminalFrame!.height - TOPSPACE - tabbarheight!, width: 50, height: 30))
        //    animateButton = AnimatedButton(frame: CGRect(x: 0, y: (terminalFrame!.height - TOPSPACE) - (tabbarheight! - 30), width: 50, height: 30))
        self.addSubview(animateButton!)
        animateButton!.didTapped = { (button) -> () in
            self.triggerAction()
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
                    UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                        self.frame = self.terminalFrame!
                        }, completion: nil)
                    
                    UIView.animateWithDuration(0.3, delay: 0.2, options: .CurveEaseOut, animations: { () -> Void in
                        self.normalRect.center = CGPoint(x: self.normalRect.center.x, y: 100)
                        self.blurView.alpha = 1.0
                        }, completion: nil)
                    
                    UIView.animateWithDuration(1.0, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                        self.springRect.center = CGPoint(x: self.springRect.center.x, y: 100)
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
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                self.frame = self.initialFrame!
                }, completion: nil)
            
            UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                self.normalRect.center = CGPoint(x: self.normalRect.center.x, y: UIScreen.mainScreen().bounds.size.height - 30 - 50)
                self.blurView.alpha = 0.0
                }, completion: nil)
            
            UIView.animateWithDuration(0.2, delay:0.0, options: .CurveEaseOut, animations: { () -> Void in
                self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.mainScreen().bounds.size.height - 30 - 50 + 10)
                }, completion: { (finish) -> Void in
                    UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                        self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.mainScreen().bounds.size.height - 30 - 50 - 40)
                        }, completion: { (finish) -> Void in
                            UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: { () -> Void in
                                self.springRect.center = CGPoint(x: self.springRect.center.x, y: UIScreen.mainScreen().bounds.size.height - 30 - 50)
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
        
        diff = normalRectFrame.origin.y - springRectFrame.origin.y
        print("=====\(diff)")
        
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
        animationCount--
        if animationCount == 0
        {
            displayLink.invalidate()
            displayLink = nil
        }
    }
    
    
}
