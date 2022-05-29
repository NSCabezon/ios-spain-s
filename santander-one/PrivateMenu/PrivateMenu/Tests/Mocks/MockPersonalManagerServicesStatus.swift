//
//  MockPersonalManagerServicesStatus.swift
//  PrivateMenu-Unit-Tests
//
//  Created by Felipe Lloret on 5/5/22.
//

import CoreDomain

struct MockPersonalManagerServicesStatus: PersonalManagerServicesStatusRepresentable {
    var managerWallEnabled: Bool
    var managerWallVersion: Double
    var enableManagerNotifications: Bool
    var videoCallEnabled: Bool
    var videoCallSubtitle: String?
    var userId: String?
}
