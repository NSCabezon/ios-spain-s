//
//  LoginDebugSetup.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/30/20.
//

import Foundation
public struct LoginDebugSetup {
    
    public var defaultUser: String?
    public var defaultMagic: String?
    
    public init?(defaultUser: String?, defaultMagic: String?) {
        guard let defaultUser = defaultUser, let defaultMagic = defaultMagic else { return nil }
        self.defaultMagic = defaultMagic
        self.defaultUser = defaultUser
    }
}
