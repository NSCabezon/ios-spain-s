//
//  PersonalManagerAvailableFeaturesRepresentable.swift
//  CoreDomain
//
//  Created by Boris Chirino Fernandez on 10/2/22.
//

public protocol PersonalManagerServicesStatusRepresentable {
    var managerWallEnabled: Bool { get }
    var managerWallVersion: Double { get }
    var enableManagerNotifications: Bool { get }
    var videoCallEnabled: Bool { get }
    var videoCallSubtitle: String? { get }
    var userId: String? { get }
}
