//
//  GlobalSearchConfigurationModifier.swift
//  GlobalSearch
//
//  Created by Luis Escámez Sánchez on 17/6/21.
//

import Foundation

public protocol GlobalSearchConfigurationModifierProtocol {
    var isMainOperativesSectionEnabled: Bool { get }
    var isTransactionSearchEnabled: Bool { get }
    var isInterestsTipsSearchEnabled: Bool { get }
    var isSegmentedControlEnabled: Bool { get }
    var isActionsSearchEnabled: Bool { get }
}
