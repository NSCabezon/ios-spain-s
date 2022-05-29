//
//  UpdateUserPrefences.swift
//  Onboarding
//
//  Created by Jose Ignacio de Juan Díaz on 30/12/21.
//

import Foundation

public protocol UpdateUserPreferencesRepresentable {
    var userId: String { get }
    var alias: String? { get }
    var globalPositionOptionSelected: GlobalPositionOptionEntity? { get }
    var photoThemeOptionSelected: Int? { get }
    var pgColorMode: PGColorMode? { get }
    var isPrivateMenuCoachManagerShown: Bool? { get }
}
