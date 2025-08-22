//
//  Progress+MNExtension.swift
//  MNFoundation
//
//  Created by MNFoundation on 2021/8/1.
//

import Foundation

extension Progress {
    
    /**百分比*/
    public var percent: Int {
        let behavior: NSDecimalNumberHandler = NSDecimalNumberHandler(roundingMode: .down, scale: 0, raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: false)
        let result: NSDecimalNumber = NSDecimalNumber(value: fractionCompleted).multiplying(by: NSDecimalNumber(value: 100.0), withBehavior: behavior)
        return result.intValue
    }
}
