//
//  AccountAvailableBalanceDelegate.swift
//  GlobalPosition
//
//  Created by Gabriel Tondin on 23/03/2021.
//

import Foundation

public protocol AccountAvailableBalanceDelegate: AnyObject {
    func isEnabled() -> Bool
}
