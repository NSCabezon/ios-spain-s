//
//  AtmElementViewModel.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 10/29/20.
//

import CoreFoundationLib
import Foundation

final class AtmElementViewModel {
    var localizedKey: String
    var isAvailable: Bool
    
    init(localizedKey: String, isAvailable: Bool) {
        self.isAvailable = isAvailable
        self.localizedKey = localizedKey
    }
}
