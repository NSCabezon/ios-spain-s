//
//  DigitalProfileCellModel.swift
//  PersonalArea
//
//  Created by Carlos Monfort Gómez on 08/03/2021.
//

import CoreFoundationLib
import CoreDomain

struct DigitalProfileCellModel {
    let title: String
    let done: Bool
    let accassibilityIdentifier: String?
}

struct DigitalProfileCarrouselCellModel {
    let title: LocalizedStylableText
    let titleNum: String
    let cells: [DigitalProfileElemProtocol]
    let titleAccassibilityIdentifier: String
    let titleNumAccassibilityIdentifier: String
}
