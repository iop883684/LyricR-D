//
//  LyricParse.swift
//  LiveLabel
//
//  Created by Degree on 10/4/17.
//  Copyright © 2017 HeheData. All rights reserved.
//

import UIKit

enum SingerType {
    case non
    case male
    case female
    case duet
}

struct LyricLine {
    var starTime:Float = 0
    var endTime:Float = 0
    var times = [Float]()
    var words = [String]()
    var graph = [Graph]()
    var type = SingerType.non
    var isStartStep = false  //to show avatar of duet mode
    var countDown = false
}

struct SongInfo{
    var title = ""
    var artist = ""
    var album = ""
    var offset = 0
    var startTime:Float = -1
}

enum Graph{
    case normalPoint
    case startPoint
    case bridgePoint
    case endPoint
    case longPoint
    
}

class LyricParse: NSObject {
    
    var dataSong:SongInfo!
    var lines = [LyricLine]()
    
   func parse(fromFile path: String)  {

        do {
            let raw = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            let rawLines = raw.components(separatedBy: "\n")
            dataSong = self.parseRawLRC(rawLines)
            
        } catch  {
            print("Error", error.localizedDescription)
        }
        
    }
    
    func parse(fromString raw: String){
        
        let rawLines = raw.components(separatedBy: "\n")
        dataSong = self.parseRawLRC(rawLines)
        
    }
    
    //WARNING: can phai sua return multi line
    
    func getListCurrentRow(forTime currentTime: Double) -> [Int] {
        
        var currentRow: Int = 0
        var listRow = [Int]()
        
        for currentLine in lines {
            
            if currentTime > Double(currentLine.starTime ){
                if currentTime < Double(currentLine.endTime ){
                    listRow.append(currentRow)
                }
            }
            
            currentRow += 1
            
        }
        return listRow
    }
    
    /*
    func getCurrentRow(forTime currentTime: Double) -> Int {
        
        var currentRow: Int = 0
        
        for currentLine in lines {

            if currentTime > Double(currentLine.starTime ){
                if currentTime < Double(currentLine.endTime ){
                    return currentRow
                }
            }
     
            currentRow += 1
            
        }
        return -1
    }
 */
    
    func getActiveRow(forTime currentTime: Double) -> IndexSet {
        
        let listRow = NSMutableIndexSet()
        var index = 0
        
        for currentLine in lines {
            
            if currentTime > Double(currentLine.starTime ){
                if currentTime < Double(currentLine.endTime ){
                    listRow.add(index)
                }
            }
            index += 1
        }
        
        return listRow as IndexSet
        
    }

     func parseRawLRC(_ rawLines: [String]) -> SongInfo {
        
        var result = SongInfo()
        
        lines = [LyricLine]()
        var offset: Int = 0
        var curType = SingerType.non
        
        for rawLine: String in rawLines {    
             if rawLine.count > 2 {
                let first: String = (rawLine as NSString).substring(with: NSRange(location: 1, length: 2))
                if Scanner(string: first).scanFloat(nil) {
                    // Change the first timestamp block [01:07.609] to <01:07.609>
                    var line = LyricLine()
                    var timeArr = [Float]()
                    var textArr = [String]()
                    var type = SingerType.non
                    
                    let arrowedString = NSMutableString(string: rawLine)
                    arrowedString.replaceOccurrences(of: "[", with: "<", options: .caseInsensitive, range: NSRange(location: 0, length: (rawLine.count )))
                    arrowedString.replaceOccurrences(of: "]", with: ">", options: .caseInsensitive, range: NSRange(location: 0, length: (rawLine.count )))
                    
                    let timestampedWords = arrowedString.components(separatedBy: "<")
                    
                    for timestampedWord: String in timestampedWords {
                        var word = timestampedWord.components(separatedBy: ">")
//                        print("one cell", word)
                        if word.count > 0 {
                            // Convert the timestamp to something usable
                            let timing: String = word[0]
                            if timing.count > 0 {
                                var time: Float = 0.0
                                var timeComponents = timing.components(separatedBy: ":")
                                if timeComponents.count == 2 {
                                    let minutes = Int(timeComponents[0]) ?? 0
                                    let seconds = Float(timeComponents[1]) ?? 0.0
                                    time = Float(minutes * 60) + seconds - Float(offset)
                                }

                                timeArr.append(time)
                            }
                            
                        }
                        if word.count > 1 
                        {
                            var text: String = word[1]
                            if text.count > 0 && text != "\r" {
//                                print("add text", text)
                                if text.hasPrefix("F:"){
                                    type = SingerType.female
                                    text = String(text.dropFirst(2))
                                } else if text.hasPrefix("M:"){
                                    type = SingerType.male
                                    text = String(text.dropFirst(2))
                                } else if text.hasPrefix("D:"){
                                    type = SingerType.duet
                                    text = String(text.dropFirst(2))
                                }
                                
                                textArr.append(text)
                            }
                        }
                    }
                    
                    if curType != type {
                        curType = type
                        line.isStartStep = true
                    }
                    
                    if timeArr.count > 0{
                        if textArr[0].contains("Bài") && textArr[1].contains("hát") {
                            result.title = textArr.joined(separator: " ").replacingOccurrences(of: "Bài  hát:", with: "")
                        } else if textArr[0].contains("Ca") && textArr[1].contains("sĩ") {
                            result.artist = textArr.joined(separator: " ").replacingOccurrences(of: "Ca  sĩ:", with: "")
                        } else {
                            
                            line.starTime = timeArr.first ?? 0
                            line.endTime = timeArr.last ?? 0
                            line.times = timeArr
                            line.words = textArr
                            line.type = type
                            lines.append(line)
//                            print(line.words)
                            
                            if result.startTime == -1 {
                                result.startTime = line.starTime
                                print("Start time", result.startTime)
                            }
                            
                            
                        }

                    }
                    
                    
                } else {
                    
                    let toTrim = CharacterSet(charactersIn: "[]")
                    var property: String = rawLine.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                    property = property.trimmingCharacters(in: toTrim)
                    var components = property.components(separatedBy: ":")
                    if components.count == 2 {
                        
                        if (components[0] == "ti") {
                            result.title = components[1]
                        }
                        if (components[0] == "ar") {
                            result.artist = components[1]
                        }
                        if (components[0] == "al") {
                            result.album = components[1]
                        }
                        if (components[0] == "offset") {
                            result.offset = Int(components[1]) ?? 0
                            offset = Int(components[1]) ?? 0
                        }
                    }
                    
                }
                
            }

        }
        
        return result
        
    }
    
    class func humanReadableLine(_ timestampedWords: [[String]]) -> String {
        var line = ""
        for timestampedWord in timestampedWords {
            if timestampedWord.count == 2 {
                line = "\(line)\(timestampedWord[1])"
            }
        }
        return line
    }
    
    class func humanReadableLine(_ timestampedWords: [[String]], for i: Int) -> NSAttributedString {
        let pastAttrs = [NSAttributedStringKey.foregroundColor: UIColor.green]
        let futureAttrs = [NSAttributedStringKey.foregroundColor: UIColor.black]
        let line = NSMutableAttributedString()
        var index: Int = 0
        for timestampedWord in timestampedWords {
            if timestampedWord.count == 2 {
                let attrs = index <= i ? pastAttrs : futureAttrs
                let word = NSAttributedString(string: timestampedWord[1], attributes: attrs)
                line.append(word)
            }
            index += 1
        }
        return line
    }



}
