//
//  SantanderKeyFirstLoginModifierProtocol.swift
//  RetailLegacy
//
//  Created by David Gálvez Alonso on 12/4/22.
//

import Foundation

public protocol SantanderKeyFirstLoginModifierProtocol {
    func evaluateSanKey(completion: @escaping (Bool) -> Void)
}

extension SantanderKeyFirstLoginModifierProtocol {
    
    func evaluateSanKey(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
}
