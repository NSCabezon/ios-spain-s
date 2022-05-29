//
//  AppIcon.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 27/12/21.
//

import Foundation

public protocol AppIconRepresentable {
    var startDate: String { get }
    var endDate: String { get }
    var iconName: String { get }
}
