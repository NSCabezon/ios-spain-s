//
//  PhotoThemeOption.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 2/12/21.
//

import Foundation

public enum PhotoThemeOption: Int {
    case geographic = 0
    case pets
    case geometric
    case architecture
    case youngs
    case nature
    case sports
    
    public func value() -> Int {
        return self.rawValue
    }
}
