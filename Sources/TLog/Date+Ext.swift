//
//  File.swift
//  
//
//  Created by Nguyen, Thinh on 02/06/2023.
//

import Foundation

extension Date {
    func toString() -> String {
        TLog.dateFormatter.string(from: self as Date)
    }
}
