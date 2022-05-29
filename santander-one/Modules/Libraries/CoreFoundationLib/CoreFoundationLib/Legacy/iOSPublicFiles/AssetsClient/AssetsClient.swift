//
//  AssetsClient.swift
//  iOS-Public-Files
//
//  Created by Johann Casique on 07/02/2018.
//  Copyright © 2018 Johann Casique. All rights reserved.
//

import Foundation

public struct AssetsClient {
    
    public init() { }
    
    public func get(path: String) -> String?  {
        let path = (Bundle.main.bundlePath as NSString).appendingPathComponent(path)
        guard let data = FileManager.default.contents(atPath: path) else {
            return nil
        }
        guard let dataToString = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        return dataToString
    }
    
}
