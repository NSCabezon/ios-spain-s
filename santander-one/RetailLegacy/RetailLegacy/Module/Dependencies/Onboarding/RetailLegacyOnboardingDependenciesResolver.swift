//
//  RetailLegacyOnboardingDependenciesResolver.swift
//  RetailLegacy
//
//  Created by Jose Camallonga on 21/4/22.
//
import UI
import CoreFoundationLib
import Foundation

public protocol RetailLegacyOnboardingDependenciesResolver {
    func onboardingCoordinator() -> BindableCoordinator
}
