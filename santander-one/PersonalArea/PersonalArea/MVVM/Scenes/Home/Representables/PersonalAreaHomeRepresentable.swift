//
//  PersonalAreaHomeRepresentable.swift
//  PersonalArea
//
//  Created by alvola on 5/4/22.
//

import Foundation
import CoreDomain

public protocol PersonalAreaHomeRepresentable {
    var isEnabledDigitalProfileView: Bool { get }
    var digitalProfileInfo: PersonalAreaDigitalProfileRepresentable? { get }
    var isPersonalAreaSecuritySettingEnabled: Bool { get }
    var isPersonalDocOfferEnabled: Bool { get }
    var isRecoveryOfferEnabled: Bool { get }
}

public protocol PersonalAreaDigitalProfileRepresentable {
    var digitalProfilePercentage: Double? { get }
    var digitalProfileType: DigitalProfileEnum? { get }
}
