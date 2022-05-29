//
//  SanKeyValidatorDelegate.swift
//  RetailLegacy
//
//  Created by Andres Aguirre Juarez on 11/11/21.
//

import Foundation

public protocol SanKeyValidatorDelegate: class {
    func success(deviceToken: String, footprint: String, onCompletion: @escaping (Bool, String?) -> Void)
    func continueSignProcess()
    func biometryDidSuccessfullyDisappear()
    func biometryDidDisappear(withError error: String?)
    func getScreen() -> String
}
