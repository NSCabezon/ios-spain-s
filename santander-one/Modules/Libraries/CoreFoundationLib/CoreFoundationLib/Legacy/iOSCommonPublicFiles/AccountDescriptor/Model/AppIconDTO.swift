//
//  AppIconDTO.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 23/09/2020.
//  Copyright © 2020 Johann Casique. All rights reserved.
//

import Foundation

public struct AppIconDTO: Codable {
    public let startDate: String?
    public let endDate: String?
    public let iconName: String?
    
    public init(startDate: String? = nil, endDate: String? = nil, iconName: String? = nil) {
        self.startDate = startDate
        self.endDate = endDate
        self.iconName = iconName
    }
}
