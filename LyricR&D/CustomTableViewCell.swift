//
//  CustomTableViewCell.swift
//  LyricR&D
//
//  Created by DoLH on 5/11/18.
//  Copyright © 2018 DoLH. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    struct APoint {
        var start = CGPoint.zero
        var end = CGPoint.zero
    }
    
    @IBOutlet var lbLyric:UILabel!
//    var bezierPath: UIBezierPath!
    var poinList = [APoint]()
    var graphs = [Graph]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func isFirstPart(firstWord:String)->Bool{
        
        let word = firstWord.replacingOccurrences(of: " ", with: "")
        if let firstChar = word.first{
            let cs = String(firstChar)
            if cs == cs.uppercased() && (cs != cs.lowercased()) {
//                lbLyric.textAlignment = .left
                return true
            }
        }
//        lbLyric.textAlignment = .right
        return false
        
    }
    
    //LyricLine(starTime: 109.099998, endTime: 111.93,
    //times: [109.099998, 109.459999, 109.910004, 110.75, 111.059998, 111.5, 111.93],
    //words: ["Nhìn ", "trên ", "cao ", "khoảng ", "Trời ", "yêu"],
    //type: LyricR_D.SingerType.non, isStartStep: false, countDown: false)
    
    func setContentCell(line:LyricLine, graphLine:[Graph]) {
        
//        print(line.times)
//        print(line.words)
//        print(graphLine)
        graphs = graphLine
        lbLyric.text = line.words.joined()
        let str:NSString = line.words.joined() as NSString
        
        var startOfLyric:CGFloat = 0
        let firstPart = isFirstPart(firstWord: line.words[0])
        if firstPart {
            lbLyric.textAlignment = .left
            startOfLyric = 15
        } else{
            lbLyric.textAlignment = .right
            
            let size: CGSize = str.size(withAttributes: [ NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17.0)])
            startOfLyric = UIScreen.main.bounds.width - 15 - size.width
        }

        var wordIndex = 0
        var currentWord = ""
        
        poinList.removeAll()
        
        for word in line.words{
            
//            let range:NSRange  = str.range(of: word)
//            let prefix = (str as NSString).substring(to: range.location)
            currentWord = currentWord.appending(word)
            
            let size: CGSize = currentWord.size(withAttributes: [ NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17.0)])
            
            var startPoint = CGPoint.init(x: 0 + startOfLyric, y: 40)
            
            if wordIndex != 0 {
                
                startPoint = poinList[wordIndex-1].end
                
            }
            
            let endPoint  = CGPoint(x:size.width + startOfLyric, y:40);

            let point = APoint(start: startPoint, end: endPoint)
            poinList.append(point)
            
            wordIndex += 1
        }
        
        self.layer.sublayers?.forEach {
            if $0.isKind(of: CAShapeLayer.self){
                $0.removeFromSuperlayer()
            }
            
        }
        
        drawTheLine()
        
        

    }
    
    func drawTheLine(){
        
        var index = 0
        
        for aPoint in poinList {
            
            let shapeLayer = CAShapeLayer()
            //        shapeLayer.name = "ShapeLayer"
            shapeLayer.strokeColor = UIColor.red.cgColor
            
            let bezierPath = UIBezierPath()
//            UIColor.red.setStroke()
            
            let curPoint = graphs[index+1]
            
            if curPoint == Graph.normalPoint {
                
                bezierPath.move(to: aPoint.start)
                bezierPath.addLine(to: aPoint.end)
                
            } else if curPoint == Graph.startPoint {
                
                var startP = aPoint.start
                startP.x += 10
                startP.y -= 10
                
                bezierPath.move(to: startP)
                
                var c1 = aPoint.start
                c1.x += 10
                c1.y -= 5
                
                var c2 = aPoint.start
                c2.x += 15
                
                bezierPath.addCurve(to: aPoint.end,
                                    controlPoint1: c1,
                                    controlPoint2: c2)
                
            } else if curPoint == Graph.endPoint {
                
                
                bezierPath.move(to: aPoint.start)
                
                var c1 = aPoint.end
                c1.x -= 15
                
                var c2 = aPoint.end
                c2.x -= 10
                c2.y -= 5
                
                var endP = aPoint.end
                endP.x -= 10
                endP.y -= 10
                
                bezierPath.addCurve(to: endP,
                                    controlPoint1: c1,
                                    controlPoint2: c2)
                
                
            } else if curPoint == .longPoint {
                
                shapeLayer.strokeColor = UIColor.green.cgColor
                
                var startP = aPoint.start
                startP.y -= 10
                bezierPath.move(to: startP)
                
                var endP = aPoint.end
                endP.y -= 10
                
                bezierPath.addCurve(to: endP,
                                    controlPoint1: aPoint.start,
                                    controlPoint2: aPoint.end)
                
            } else {
                
                bezierPath.move(to: aPoint.start)
                bezierPath.addLine(to: aPoint.end)
                
            }
            
            index += 1
            
            
            bezierPath.lineWidth = 1
//            bezierPath.stroke()
            
            
            shapeLayer.path = bezierPath.cgPath
            
            //change the fill color
            shapeLayer.fillColor = UIColor.clear.cgColor
            //you can change the line width
            shapeLayer.lineWidth = 1
            
//            shapeLayer.strokeColor = UIColor(red: 96/255, green: 96/255, blue: 96/255, alpha: 1).cgColor
            
            
            self.layer.addSublayer(shapeLayer)
            
            
        }
        
        

        
    }


    override func draw(_ rect: CGRect) {
        
        print("draw rect")
        
        super.draw(rect)
        //// Bezier Drawing
        
        
        


  
    }

}
