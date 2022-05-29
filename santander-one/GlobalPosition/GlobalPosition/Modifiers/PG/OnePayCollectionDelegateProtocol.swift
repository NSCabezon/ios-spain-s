//
//  OnePayCollectionDelegateProtocol.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 23/02/2021.
//

import Foundation

public protocol OnePayCollectionDelegateProtocol: AnyObject {
    func showToast()
    func canGoToNewShipment() -> Bool
}
