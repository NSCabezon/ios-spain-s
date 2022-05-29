//
//  MockPersonalManager.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain

struct MockPersonalManager: PersonalManagerRepresentable {
    var codGest: String?
    var nameGest: String?
    var category: String?
    var portfolio: String?
    var desTipCater: String?
    var phone: String?
    var email: String?
    var indPriority: Int?
    var portfolioType: String?
    var thumbnailData: Data?
}
