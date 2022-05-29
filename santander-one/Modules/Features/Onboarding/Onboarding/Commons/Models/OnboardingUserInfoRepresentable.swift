//
//  OnboardingUserInfo.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 27/12/21.
//

import Foundation
import CoreDomain

protocol OnboardingUserInfoRepresentable {
    var id: String { get }
    var name: String { get }
    var alias: String? { get }
    var globalPosition: GlobalPositionOptionEntity { get }
    var pgColorMode: PGColorMode { get }
    var photoTheme: Int? { get }
}
