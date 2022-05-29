//
//  Parser.swift
//  CoreFoundationLib
//
//  Created by Johann Casique on 08/02/2018.
//  Copyright © 2018 Johann Casique. All rights reserved.
//

import Foundation

public protocol Parser {
    
    associatedtype Parseable
    
    func serialize(_ responseString : String) -> Parseable?
    
    func deserialize(_ parseable : Parseable) -> String?
}
