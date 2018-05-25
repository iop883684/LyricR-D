//
//  LyricAnimation.swift
//  LiveLabel
//
//  Created by Degree on 10/5/17.
//  Copyright © 2017 HeheData. All rights reserved.
//

import UIKit


class LablelAnimation: UILabel, CAAnimationDelegate {
    
    let animationFontSize:CGFloat = 22
    
    var textLayer:CATextLayer?
    var animation = CAKeyframeAnimation()
    
    func resestTexlayer(){
        
        if let _ = textLayer {
            textLayer?.removeAnimation(forKey: "key")
            textLayer?.removeFromSuperlayer()
        }
        
        
        textLayer = CATextLayer()
        
        textLayer?.anchorPoint = CGPoint(x: 0, y: 0.5)
        textLayer?.frame = self.bounds
        textLayer?.foregroundColor = UIColor.yellow.cgColor
        textLayer?.masksToBounds = true
        
        textLayer?.font = UIFont.systemFont(ofSize: animationFontSize, weight: .medium)//labelAnimation.font
        textLayer?.fontSize = animationFontSize
        textLayer?.alignmentMode = kCAAlignmentLeft
        textLayer?.isWrapped = true
        textLayer?.string = self.text
        self.layer.addSublayer(textLayer!)
        
    }
    
    func startAnimation(for line:LyricLine){
        
        self.text = line.words.joined(separator: "")
        self.textColor = UIColor(white: 1, alpha: 1)
        
        self.resestTexlayer()
        
//        if line.type == .male{
//            textLayer?.foregroundColor = UIColor.cyan.cgColor
//        } else if line.type == .female {
//            textLayer?.foregroundColor = UIColor.magenta.cgColor
//        } else if line.type == .duet {
//            textLayer?.foregroundColor = UIColor.blue.cgColor
//        }
        
        animation = textAnimation(line: line)
        textLayer?.add(animation, forKey: "key")
        
    }
    
    
    private func textAnimation(line:LyricLine)->CAKeyframeAnimation{
        
        
        var keyTime = [NSNumber]()
        var widths = [CGFloat]()
        
        let startTime = line.starTime
        let endTime = line.endTime
        let maxTime = endTime - startTime
        for time in line.times {
            
            let value = (time - startTime)/maxTime
            keyTime.append(NSNumber(value:value))
            //            widths.append(CGFloat(value)*width)
            
        }
        
        widths = valuesFromLyricSegment(lyricSegment: line.words)
        
//        print("key", keyTime)
//        print("width", widths)
//        print("duration", maxTime)
        
        //test animation
        let animation = CAKeyframeAnimation(keyPath: "bounds.size.width")
        animation.duration = CFTimeInterval(maxTime)
        animation.values = widths
        animation.keyTimes = keyTime
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.isRemovedOnCompletion = true
        animation.delegate = self
        
        return animation
        
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        textLayer?.removeFromSuperlayer()
        self.textColor = UIColor.init(white: 0.5, alpha: 1)
    }
    
    
    private func valuesFromLyricSegment(lyricSegment:[String]) -> [CGFloat] {
        
        let font = UIFont.systemFont(ofSize: animationFontSize, weight: .medium)
        // Init a mutable array and init with zero as first element
        // The width of CALayer will start at 0.0
        var lyricParts = [CGFloat]()
        lyricParts.append(0.0)
        
        var val: CGFloat = 0
        for str: String in lyricSegment {
//            print("str", str)
            let strWidth: CGFloat? = str.size(withAttributes: [NSAttributedStringKey.font: font]).width
            val = val + strWidth!
            lyricParts.append(val)
        }

        return lyricParts
    }
    
    func pauseAnimation(){
        
        if let layer = textLayer{
            let pauseTime = layer.convertTime(CACurrentMediaTime(), from: nil)
            layer.speed = 0.0
            layer.timeOffset = pauseTime
        }
        
    }
    
    func resumeAnimation(){
        
        if let layer = textLayer{
            let pauseTime = layer.timeOffset
            layer.speed = 1.0
            layer.timeOffset = 0.0
            layer.beginTime = 0.0
            layer.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) - pauseTime
            
        }

    }
    
    func stopAnimation(){
        
        textLayer?.removeAnimation(forKey: "key")
        textLayer?.removeFromSuperlayer()
        
    }

}
