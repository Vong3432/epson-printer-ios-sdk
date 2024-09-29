//
//  String+Extensions.swift
//  PrinterFramework
//
//  Created by nyuksoon.vong on 20/3/24.
//

import Foundation

extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String {
        let stringLength = self.count
        if stringLength < toLength {
            return String(repeatElement(character, count: toLength - stringLength)) + self
        } else {
            return String(self.suffix(toLength))
        }
    }
}

// Utility: Pads two strings to columns per line
func padLine(partOne: String?, partTwo: String?, columnsPerLine: Int, tabIndent: Int) -> String {
    let partOne = partOne ?? ""
    let partTwo = partTwo ?? ""
    var concat: String
    
    if (partOne.count + partTwo.count) > columnsPerLine {
        
        let p1Count = partOne.count
        let p2Count = partTwo.count
        
        let wrappedTextLen = p1Count - p2Count
        let shouldWrapRightSide = wrappedTextLen < 0 || p1Count > p2Count
        
        if shouldWrapRightSide {
            let wrappedText = String(partTwo.prefix(abs(wrappedTextLen)))
            if wrappedText == partTwo { return partTwo }
            concat = padLine(
                partOne: partOne,
                partTwo: wrappedText,
                columnsPerLine: columnsPerLine,
                tabIndent: tabIndent
            )
            
            let nextLineText = String(partTwo.suffix(p2Count - abs(wrappedTextLen)))
            let padded = "".leftPadding(toLength: columnsPerLine - nextLineText.count, withPad: " ")
            concat += padLine(
                partOne: nil,
                partTwo: "\(padded)\(nextLineText)",
                columnsPerLine: columnsPerLine,
                tabIndent: tabIndent
            )
        } else {
            let wrappedText = String(partOne.prefix(wrappedTextLen))
            concat = padLine(
                partOne: wrappedText,
                partTwo: partTwo,
                columnsPerLine: columnsPerLine,
                tabIndent: tabIndent
            )
            
            let padded = "".leftPadding(toLength: tabIndent, withPad: " ")
            let nextLineText = String(partOne.suffix(p1Count - wrappedTextLen))
            concat += padLine(
                partOne: "\n\(padded)\(nextLineText)",
                partTwo: nil,
                columnsPerLine: columnsPerLine,
                tabIndent: tabIndent
            )
        }
    } else {
        let padding = columnsPerLine - (partOne.count + partTwo.count)
        concat = partOne + String(repeating: " ", count: padding) + partTwo
    }
    return concat
}

// Utility: String repeat
func repeatString(str: String, count: Int) -> String {
    return String(repeating: str, count: count)
}
