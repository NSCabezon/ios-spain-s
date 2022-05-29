//
//  OtherOperativesModifierProtocol.swift
//  GlobalPosition
//
//  Created by David Gálvez Alonso on 15/03/2021.
//

import CoreFoundationLib

public protocol OtherOperativesModifierProtocol: AnyObject {
    var isStockAccountsDisabled: Bool { get }
    func isOtherOperativeEnabled(_ option: PGFrequentOperativeOption) -> Bool
    func performAction(_ values: OperativeActionValues)
}
