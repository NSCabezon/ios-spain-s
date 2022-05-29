//
//  SantanderKeyUpdateTokenModifierProtocol.swift
//  RetailLegacy
//
//  Created by Ali Ghanbari Dolatshahi on 25/4/22.
//

import Foundation

public protocol SantanderKeyUpdateTokenModifierProtocol {
    func updateToken(completion: @escaping (Bool) -> Void)
}

extension SantanderKeyUpdateTokenModifierProtocol {
    
    func updateToken(completion: @escaping (Bool) -> Void) {
        completion(false)
    }
}
