//
//  OtherOperativesActionModifier.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 2/5/21.
//

import CoreFoundationLib
import Foundation

public protocol AccountOtherOperativesActionModifierProtocol: AnyObject {
    func didSelectAction(_ action: AccountActionType, _ entity: AccountEntity)
}
