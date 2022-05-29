//
//  FileManager.swift
//  CoreFoundationLib
//
//  Created by Johann Casique on 12/02/2018.
//  Copyright © 2018 Johann Casique. All rights reserved.
//

import Foundation

public extension FileManager {
    static var documentDirectoryURL: URL {
        return try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
    }
}
