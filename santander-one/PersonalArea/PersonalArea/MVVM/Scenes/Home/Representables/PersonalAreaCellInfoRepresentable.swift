//
//  PersonalAreaCellInfoRepresentable.swift
//  PersonalArea
//
//  Created by alvola on 11/4/22.
//

import Foundation

public protocol PersonalAreaCellInfoRepresentable {
    var cellClass: String { get }
    var info: Any? { get }
    var goToSection: PersonalAreaSection? { get }
    var action: PersonalAreaAction? { get }
    var customAction: CustomAction? { get }
}
