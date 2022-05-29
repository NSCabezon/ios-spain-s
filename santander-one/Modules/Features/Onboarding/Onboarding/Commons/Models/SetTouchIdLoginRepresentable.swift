//
//  SetTouchIdLoginRepresentable.swift
//  Onboarding
//
//  Created by José Norberto Hidalgo Romero on 12/1/22.
//

import Foundation

public protocol SetTouchIdLoginRepresentable {
    var deviceMagicPhrase: String? { get }
    var touchIDLoginEnabled: Bool? { get }
}
