//
//  ClassicConfiguration.swift
//  GlobalPosition
//
//  Created by Rubén Márquez Fernández on 1/7/21.
//

import Foundation
import CoreDomain
import CoreFoundationLib
import CoreDomain

struct ClassicConfiguration {
    let isPb: Bool
    let userId: String?
    var userName: String
    let isYourMoneyVisible: Bool
    let userBirthday: Date?
    var collapsed: [ProductTypeEntity: Bool]
    let enableMarketplace: Bool?
    let isAnalysisAreaEmpty: Bool?
    let isSmartUser: Bool?
    var orderedBoxes: [UserPrefBoxType]
    let isTimeLineEnabled: Bool
    let isPregrantedSimulatorEnabled: Bool
    var isOnePayCarouselEnabled: Bool
    let isSanflixEnabled: Bool?
    let isPublicProductEnable: Bool?
    let isFinanzingZoneEnabled: Bool
    let enableStockholders: Bool
    let frequentOperatives: [PGFrequentOperativeOptionProtocol]?
    let isWhatsNewZoneEnabled: Bool
    let isCarbonFootprintEnabled: Bool
}
