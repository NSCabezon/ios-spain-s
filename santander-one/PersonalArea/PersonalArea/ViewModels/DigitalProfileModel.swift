//
//  DigitalProfileModel.swift
//  PersonalArea
//
//  Created by alvola on 11/11/2019.
//

import Foundation
import CoreDomain
import CoreFoundationLib

struct DigitalProfileModelWithUser {
    let digitalProfile: DigitalProfileEnum
    let username: String
    let userLastname: String
    let userImage: Data?
    let percentage: Double
    
    init(username: String, userLastname: String, userImage: Data?, digitalProfile: DigitalProfileEnum, percentage: Double) {
        self.username = username
        self.userLastname = userLastname
        self.userImage = userImage
        self.digitalProfile = digitalProfile
        self.percentage = percentage
    }
}

struct DigitalProfileModel {
    let percentage: Double
    let type: DigitalProfileEnum
    let titleAccessibilityIdentifier: String
    let badgeIconAccessibilityIdentifier: String
    let progressBarAccessibilityIdentifier: String
    let progressPercentageAccessibilityIdentifier: String
    let descriptionAccessibilityIdentifier: String
}
