//
//  RetailLegacyExternalDependenciesResolver.swift
//  Account
//
//  Created by Juan Carlos López Robles on 12/16/21.
//
import UI
import Foundation
import CoreFoundationLib
import FeatureFlags

public protocol RetailLegacyExternalDependenciesResolver:
    LegacyCoreDependenciesResolver,
    RetailLegacyMenuExternalDependenciesResolver,
    RetailLegacyLoanExternalDependenciesResolver,
    RetailLegacyFundExternalDependenciesResolver,
    RetailLegacyOnboardingDependenciesResolver,
    RetailLegacySavingsExternalDependenciesResolver,
    RetailLegacyCardExternalDependenciesResolver,
    RetailLegacyTransfersExternalDependenciesResolver,
    FeatureFlagsExternalDependenciesResolver,
    RetailLegacyPrivateMenuExternalDependenciesResolver,
    RetailLegacyCardExternalDependenciesResolver,
    RetailLegacyPersonalAreaExternalDependenciesResolver {}
