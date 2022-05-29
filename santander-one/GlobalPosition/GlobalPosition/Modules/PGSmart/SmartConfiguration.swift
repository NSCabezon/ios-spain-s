//
//  SmartConfiguration.swift
//  GlobalPosition
//
//  Created by Rubén Márquez Fernández on 1/7/21.
//

import Foundation
import CoreDomain
import CoreFoundationLib

struct SmartConfiguration {
    let isPb: Bool
    var userName: String
    let userId: String?
    let isYourMoneyVisible: Bool
    let userMoney: NSAttributedString?
    let userBirthday: Date?
    let pgColorMode: PGColorMode
    let discreteMode: Bool
    let isMarketPlaceEnabled: Bool
    let isAnalysisAreaEmpty: Bool
    let isSmartOnePayCarouselEnabled: Bool
    let isSanflixEnabled: Bool
    let isPublicProductEnabled: Bool
    let isFinanzingZoneEnabled: Bool
    let frequentOperatives: [PGFrequentOperativeOptionProtocol]?
    let isWhatsNewZoneEnabled: Bool?
    let shouldShowAviosBanner: Bool
    let enableStockholders: Bool
    let isCarbonFootprintEnabled: Bool
}
