//
//  AppIconEntity.swift
//  Models
//
//  Created by David Gálvez Alonso on 23/09/2020.
//

import CoreDomain

public final class AppIconEntity: Codable {
    public let startDate: String
    public let endDate: String
    public let iconName: String

    public init(startDate: String, endDate: String, iconName: String) {
        self.startDate = startDate
        self.endDate = endDate
        self.iconName = iconName
    }
}
extension AppIconEntity: Equatable {
    public static func == (lhs: AppIconEntity, rhs: AppIconEntity) -> Bool {
        return lhs.startDate == rhs.startDate && lhs.endDate == rhs.endDate && lhs.iconName == rhs.iconName
    }
}

extension AppIconEntity: AppIconRepresentable {}
