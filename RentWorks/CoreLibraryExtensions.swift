//
//  extensions.swift
//  table view
//
//  Created by Michael Perry on 2/4/16.
//  Copyright © 2016 BYU Life Sciences. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.characters.index(self.startIndex, offsetBy: i)]
    }
}

@inline(__always) public func round(value: Float, toNearest roundBy: Float) -> Float {
    return roundBy * round(value / roundBy)
}

// makes logs to the console more informative
@inline(__always) public func log(_ logMessage: String, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    var indexOfLastForwardSlashInString = 0
    for i in 0 ..< fileName.characters.count {
        if fileName[i] == "/" {
            indexOfLastForwardSlashInString = i
        }
    }
    let className = fileName.substring(from: fileName.characters.index(fileName.startIndex, offsetBy: indexOfLastForwardSlashInString + 1))
    print("\(className) - line \(lineNumber): \(functionName): \(logMessage)")
}
@inline(__always) public func log(_ logMessage: Error, fileName: String = #file, functionName: String = #function, lineNumber: Int = #line) {
    var indexOfLastForwardSlashInString = 0
    for i in 0 ..< fileName.characters.count {
        if fileName[i] == "/" {
            indexOfLastForwardSlashInString = i
        }
    }
    let className = fileName.substring(from: fileName.characters.index(fileName.startIndex, offsetBy: indexOfLastForwardSlashInString + 1))
    print("\(className): \(lineNumber) \(functionName): \(logMessage)")
}
