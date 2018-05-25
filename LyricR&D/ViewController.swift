//
//  ViewController.swift
//  LyricR&D
//
//  Created by DoLH on 5/11/18.
//  Copyright © 2018 DoLH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tableView:UITableView!
    let parserTool = LyricParse()
    var graphs = [[Graph]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        tableView.isHidden = true
        let path = Bundle.main.path(forResource: "lyric", ofType: "lrc")
        parserTool.parse(fromFile: path!)
//        print(parserTool.lines[0])
        //point of previous sentence
        //[[LyricR_D.Graph.normalPoint, LyricR_D.Graph.normalPoint, LyricR_D.Graph.normalPoint, LyricR_D.Graph.normalPoint, LyricR_D.Graph.normalPoint, LyricR_D.Graph.normalPoint, LyricR_D.Graph.longPoint],
        
        var lineIndex = 0
        var currentTime:Float = 0
        
        
        var previousGrapLine = [Graph]()
        
        for line in parserTool.lines {
            
            print(line.times)
            var graphLine = [Graph]()
            
            var index = 0
            
            for time in line.times{
                
                var currentPoint = Graph.normalPoint
                
                if (time - currentTime) > 0.6 {
                    //easy checking
                    currentPoint = .longPoint
                    //let check previous point to mark end point
                    if index == 0 {
                        
                    } else{
                        
                        if graphLine[index-1] == .normalPoint{
                            graphLine[index-1] = .endPoint
                        } else if graphLine[index-1] == .startPoint {
                            graphLine[index-1] = .normalPoint
                        }
                        
                    }
                    
                } else  {
                    
                    if  (time - currentTime) > 0 {
                        
                        if index == 0 {
                            
                            //first word, should check previous sentence
                            if lineIndex == 0 {
                                //first line
                                currentPoint = .startPoint
                            } else{
                                
                                let previousLine = parserTool.lines[lineIndex-1]
                                let endPreTime = previousLine.times.last!
                                if (time - endPreTime) > 0.6 || previousGrapLine.last == .longPoint {
                                    //switch distance is Long
                                    currentPoint = .longPoint
                                } else{
                                    currentPoint = .normalPoint
                                }
                                
                                
                            }

                            
                        } else  {
                            
                            //word from 2 to end
                            if (graphLine[index - 1] == Graph.longPoint){
                                //if previous word is longpoint or maybe end point
                                currentPoint = .startPoint
                            } else{
                                currentPoint = .normalPoint
                            }
                            
                        }
                        
                    } else{
                        currentPoint = .normalPoint
                    }
                    
                }
                
                
                graphLine.append(currentPoint)
                
                currentTime = time
                index += 1
            }
            
//            print(graphLine)
            previousGrapLine = graphLine
            graphs.append(graphLine)
            lineIndex += 1
            
        }
        
//        print(graphs)
        
        
        
//        for line in parserTool.lines{
//
//             index = 0
//            var gr = [Graph]()
//
//            for time in line.times {
//                if let indexs = allTime.index(of: time){
//
//                } else{
//                    graphs.append(Graph.normalPoint)
//                }
//                index += 1
//            }
//
//        }
        
        
    }
    
    func processGraph(){
        
        
        var allTime = [Float]()
        var tooLong = [Float]()
        
        for line in parserTool.lines{
            
            print(line)
            allTime.append(contentsOf: line.times)
            
        }
        
        var currentTime:Float = 0
        var graphs = [Graph]()
        
        var index = 0
        
        for time in allTime {
            
            if index == 0 {
                
                graphs.append(Graph.startPoint)
                
            } else{
                
                if (time - currentTime) > 0.5 {
                    //easy checking in a line
                    tooLong.append(time)
                    graphs.append(Graph.longPoint)
                    
                } else  {
                    
                    if  (time - currentTime) > 0 && (graphs[index - 1] == Graph.longPoint) {
                        //from 2 second word
                        graphs.append(Graph.startPoint)
                    } else{
                        //start of line, should check previous line
                        graphs.append(.normalPoint)
                    }
                    
                }
                
            }
            
            currentTime = time
            index += 1
        }
        
        index = graphs.count-1
        
        
        for _ in 0...(graphs.count-1) {
            
            if graphs[index] == .longPoint{
                if graphs[index-1] != .longPoint {
                    graphs[index-1] = .endPoint
                }
            }
            print(index)
            index -= 1
        }
        
        print(graphs)
        
    }
    
   
    func isFirstSentence(firstWord:String)->Bool{
        
        let word = firstWord.replacingOccurrences(of: " ", with: "")
        if let firstChar = word.first{
            let cs = String(firstChar)
            if cs == cs.uppercased() && (cs != cs.lowercased()) {
                
                return true
            }
        }
        
        return false
        
    }


}

extension ViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parserTool.lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.setContentCell(line:parserTool.lines[indexPath.row], graphLine: graphs[indexPath.row])
        
        return cell
        
    }
    
}


