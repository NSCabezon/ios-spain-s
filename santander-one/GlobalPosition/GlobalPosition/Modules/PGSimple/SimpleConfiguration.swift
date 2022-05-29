//
//  SimpleConfiguration.swift
//  GlobalPosition
//
//  Created by Rubén Márquez Fernández on 1/7/21.
//

import Foundation
import CoreDomain
import CoreFoundationLib
import CoreDomain

struct SimpleConfiguration {
    let isPb: Bool
    var userName: String
    let isYourMoneyVisible: Bool
    let userMoney: NSAttributedString?
    let userBirthday: Date?
    let orderedBoxes: [UserPrefBoxType]
    let isSanflixEnabled: Bool
    let isPregrantedSimulatorEnabled: Bool
    var userId: String
    let frequentOperatives: [PGFrequentOperativeOptionProtocol]?
    let enableStockholders: Bool
}
