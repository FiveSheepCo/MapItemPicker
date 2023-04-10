import Foundation
import UIKit
import SchafKit

extension String {
    public func levenshtein(_ other: String) -> Int {
        let sCount = self.count
        let oCount = other.count

        guard sCount != 0 else {
            return oCount
        }

        guard oCount != 0 else {
            return sCount
        }

        let line: [Int]  = Array(repeating: 0, count: oCount + 1)
        var mat: [[Int]] = Array(repeating: line, count: sCount + 1)

        for i in 0...sCount {
            mat[i][0] = i
        }

        for j in 0...oCount {
            mat[0][j] = j
        }

        for j in 1...oCount {
            for i in 1...sCount {
                if self[i - 1] == other[j - 1] {
                    mat[i][j] = mat[i - 1][j - 1]       // no operation
                } else {
                    let del = mat[i - 1][j] + 1         // deletion
                    let ins = mat[i][j - 1] + 1         // insertion
                    let sub = mat[i - 1][j - 1] + 1     // substitution
                    mat[i][j] = min(min(del, ins), sub)
                }
            }
        }

        return mat[sCount][oCount]
    }
    
    public func damerauLevenshtein(_ target: String, max: Int?) -> Int {
        let selfCount = self.count
        let targetCount = target.count

        if self == target {
            return 0
        }
        if selfCount == 0 {
            return targetCount
        }
        if targetCount == 0 {
            return selfCount
        }
        
        // Fast Check
        
        var matching = 0
        var characters = Array(self)
        for char in target {
            if let index = characters.firstIndex(of: char) {
                matching += 1
                characters.remove(at: index)
            }
        }
        let smallestCount = min(selfCount, targetCount)
        if matching < (smallestCount * 3) / 4 {
            return smallestCount
        }
        
        // Fast Check END
        
        if let max, abs(selfCount - targetCount) >= max {
            return max
        }

        return actualDamerauLevenshtein(selfCount: selfCount, targetCount: targetCount, target: target)
    }
    
    private func actualDamerauLevenshtein(
        selfCount: Int,
        targetCount: Int,
        target: String
    ) -> Int {
        var da: [Character: Int] = [:]
        var d = Array(repeating: Array(repeating: 0, count: targetCount + 2), count: selfCount + 2)

        let maxdist = selfCount + targetCount
        d[0][0] = maxdist
        for i in 1...selfCount + 1 {
            d[i][0] = maxdist
            d[i][1] = i - 1
        }
        for j in 1...targetCount + 1 {
            d[0][j] = maxdist
            d[1][j] = j - 1
        }
        
        let selfChars = Array(self)
        let targetChars = Array(target)
        
        for i in 2...selfCount + 1 {
            var db = 1

            for j in 2...targetCount + 1 {
                let k = da[targetChars[j - 2]] ?? 1
                let l = db

                var cost = 1
                if selfChars[i - 2] == targetChars[j - 2] {
                    cost = 0
                    db = j
                }

                let substition = d[i - 1][j - 1] + cost
                let injection = d[i][j - 1] + 1
                let deletion = d[i - 1][j] + 1
                let selfIdx = i - k - 1
                let targetIdx = j - l - 1
                let transposition = d[k - 1][l - 1] + selfIdx + 1 + targetIdx

                d[i][j] = Swift.min(
                    substition,
                    injection,
                    deletion,
                    transposition
                )
            }

            da[selfChars[i - 2]] = i
        }

        return d[selfCount + 1][targetCount + 1]
    }
}
