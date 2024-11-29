//
//  String+Extensions.swift
//  PrinterFramework
//
//  Created by nyuksoon.vong on 20/3/24.
//

import Foundation

func getTokensTotal(t1: [String.SubSequence], t2: [String.SubSequence], gap: Int = 2) -> Int {
    return (t1.joined(separator: " ").count + t2.joined(separator: " ").count) + gap
}

func generateRow(partOne: String, partTwo: String, columnsPerLine: Int, tabIndent: Int) -> String {
    var partOneTokens = partOne.split(separator: " ")
    var partTwoTokens = partTwo.split(separator: " ")
    
    var result = ""
    var done = false
    
    while !done {
        
        var leftTokens = [String.SubSequence]()
        var rightTokens = [String.SubSequence]()
        var canAddToken = true
        var shouldPad = false
        
        while canAddToken {
            if let leftToken = partOneTokens.first {
                let leftPadded = String.SubSequence(stringLiteral: "".padding(toLength: tabIndent, withPad: " ", startingAt: 0))
                if getTokensTotal(t1: leftTokens + [leftPadded, leftToken], t2: rightTokens) < columnsPerLine {
                    if leftTokens.isEmpty || shouldPad {
                        leftTokens.append(leftPadded)
                        shouldPad = false
                    }
                    leftTokens.append(leftToken)
                    if partOneTokens.isEmpty == false {
                        partOneTokens.removeFirst()
                    }
                } else {
                    canAddToken = false
                    break
                }
            }
            
            if let rightToken = partTwoTokens.first {
                if getTokensTotal(t1: leftTokens, t2: rightTokens + [rightToken]) < columnsPerLine {
                    rightTokens.append(rightToken)
                    if partTwoTokens.isEmpty == false {
                        partTwoTokens.removeFirst()
                    }
                } else {
                    canAddToken = false
                    break
                }
            }
            
            let hasTokens = !(partOneTokens.isEmpty && partTwoTokens.isEmpty)
            let total = getTokensTotal(t1: leftTokens, t2: rightTokens)
            canAddToken = (total < columnsPerLine) && hasTokens
        }
        
        // Finalized
        let row = fillRow(
            left: leftTokens.joined(separator: " "),
            right: rightTokens.joined(separator: " "),
            columnsPerLine: columnsPerLine
        )
        
        print("ROW: \(row)")
        result += row
        
        if partOneTokens.isEmpty == false {
            canAddToken = true
            shouldPad = tabIndent > 0
        } else if partTwoTokens.isEmpty == false {
            canAddToken = true
        }
        
        if partOneTokens.isEmpty && partTwoTokens.isEmpty {
            done = true
        }
    }
    
    return result
}

func fillRow(left: String, right: String, columnsPerLine: Int) -> String {
    let padding = columnsPerLine - (left.count + right.count)
    return left + String(repeating: " ", count: padding > 0 ? padding : 0) + right
}

// Utility: String repeat
func repeatString(str: String, count: Int) -> String {
    return String(repeating: str, count: count)
}
