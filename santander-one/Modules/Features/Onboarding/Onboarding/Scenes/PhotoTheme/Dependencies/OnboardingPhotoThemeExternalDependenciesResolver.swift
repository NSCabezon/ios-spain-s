//
//  OnboardingPhotoThemeExternalDependenciesResolver.swift
//  Onboarding
//
//  Created by Jose Camallonga on 15/12/21.
//

import Foundation
import CoreDomain
import CoreFoundationLib
import UI

public protocol OnboardingPhotoThemeExternalDependenciesResolver: OnboardingCommonExternalDependenciesResolver {
    func resolve() -> UINavigationController
    func resolve() -> AppRepositoryProtocol
    func resolve() -> PhotoThemeModifierProtocol?
    func resolve() -> BackgroundImageRepositoryProtocol
    func resolve() -> DeleteBackgroundImageRepositoryProtocol
    func resolve() -> TrackerManager
}
