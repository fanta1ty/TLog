//
//  ViewController.swift
//  TLog
//
//  Created by thinhnguyen12389 on 06/05/2023.
//  Copyright (c) 2023 thinhnguyen12389. All rights reserved.
//

import UIKit
import TLog

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        TLog.debug("Debug !!!")
        TLog.error("Error !!!")
        TLog.info("Info !!!")
        TLog.server("Server !!!")
        TLog.verbose("Verbose !!!")
        TLog.warning("Warning !!!")
        
        /// Disable TLog
        TLog.isLoggingEnabled = false
    }
}

