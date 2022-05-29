//
//  InternalTransferModifierProtocol.swift
//  TransferOperatives
//
//  Created by Marcos Álvarez Mesa on 25/2/22.
//

import CoreDomain

public protocol InternalTransferAmountModifierProtocol {
    var isDescriptionRequired: Bool { get }
    var shoulFocusDescription: Bool { get }
    var descriptionRegularExpression: NSRegularExpression? { get }
    var inputDescriptionKey: String? { get }
}

public extension InternalTransferAmountModifierProtocol {
    var isDescriptionRequired: Bool {
        return false
    }

    var shoulFocusDescription: Bool {
        return false
    }

    var descriptionRegularExpression: NSRegularExpression? {
        return nil
    }
    
    var inputDescriptionKey: String? {
        return nil
    }
}

public class DefaultInternalTransferAmountModifier: InternalTransferAmountModifierProtocol {}
