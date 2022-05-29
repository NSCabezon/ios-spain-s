//
//  AccountHomeActionModifierProtocol.swift
//  Account
//
//  Created by Gloria Cano López on 6/9/21.
//

import CoreFoundationLib

public protocol AccountHomeActionModifierProtocol: AnyObject {
    func didSelectAction(_ action: AccountActionType, _ entity: AccountEntity)
    func getActionButtonFillViewType(for accountType: AccountActionType) -> ActionButtonFillViewType?
}
