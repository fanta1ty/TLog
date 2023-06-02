//
//  File.swift
//
//
//  Created by Nguyen, Thinh on 02/06/2023.
//

import Foundation
public enum TLogEvent: String {
    case error = "[Error ‼️]",
         info = "[Info ℹ️]",
         debug = "[Debug 🐞]",
         verbose = "[Verbose 👀]",
         warning = "[Warning ⚠️]",
         server = "[Sever 🖥️]"
}

public func print(
    _ object: Any,
    isLoggingEnabled: Bool
) {
    if isLoggingEnabled {
        Swift.print(object)
    }
}
