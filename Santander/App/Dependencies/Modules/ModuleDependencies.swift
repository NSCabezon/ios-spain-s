//
//  ModuleDependencies.swift
//  Santander
//
//  Created by Juan Carlos López Robles on 12/16/21.
//

import UI
import Loans
import Menu
import Onboarding
import CoreFoundationLib
import CoreDomain
import Foundation
import RetailLegacy
import SANSpainLibrary
import Transfer
import PrivateMenu
import SANLegacyLibrary
import SantanderKey
import PersonalArea
import ESCommons

struct ModuleDependencies {
    let oldResolver: DependenciesInjector & DependenciesResolver
    let drawer: BaseMenuViewController
    let coreDependencies = DefaultCoreDependencies()
    
    init(oldResolver: DependenciesInjector & DependenciesResolver, drawer: BaseMenuViewController) {
        self.oldResolver = oldResolver
        self.drawer = drawer
        registerExternalDependencies()
    }
    
    func resolve() -> TimeManager {
        oldResolver.resolve()
    }
    
    func resolve() -> DependenciesInjector {
        return oldResolver
    }
    
    func resolve() -> DependenciesResolver {
        return oldResolver
    }
    
    func resolve() -> AppConfigRepositoryProtocol {
        oldResolver.resolve()
    }
    
    func resolve() -> AppRepositoryProtocol {
        return oldResolver.resolve()
    }
    
    func resolve() -> TrackerManager {
        oldResolver.resolve()
    }
    
    func resolve() -> BaseMenuViewController {
        return drawer
    }
    
    func resolve() -> BSANManagersProvider {
        oldResolver.resolve()
    }
    
    func resolve() -> UINavigationController {
        drawer.currentRootViewController as?
        UINavigationController ?? UINavigationController()
    }
    
    func resolve() -> SpainTransfersRepository {
        oldResolver.resolve()
    }
    
    func resolveSideMenuNavigationController() -> UINavigationController {
        drawer.currentSideMenuViewController as? UINavigationController ?? UINavigationController()
    }
    
    func resolve() -> SegmentedUserRepository {
        oldResolver.resolve()
    }
    
    func resolve() -> PullOffersInterpreter {
        return oldResolver.resolve(for: PullOffersInterpreter.self)
    }
    
    func resolve() -> GetDigitalProfilePercentageUseCase {
        return ESGetDigitalProfilePercentageUseCase(dependencies: self)
    }
    
    func resolve() -> UseCaseHandler {
        return oldResolver.resolve()
    }
    
    func resolve() -> SpainCompilationProtocol {
        return oldResolver.resolve()
    }
}

extension ModuleDependencies: RetailLegacyExternalDependenciesResolver {
    func resolve() -> StringLoader {
        return oldResolver.resolve()
    }
    
    func resolve() -> NavigationBarItemBuilder {
        return NavigationBarItemBuilder(dependencies: self)
    }
    
    func resolve() -> GlobalPositionReloader {
        oldResolver.resolve()
    }
    
    func resolve() -> FeatureFlagsRepository {
        let flags: [FeatureFlagRepresentable] = coreFeatureFlags() + SpainFeatureFlag.allCases
        return asShared {
            DefaultFeatureFlagsRepository(features: flags)
        }
    }
    
    private func coreFeatureFlags() -> [FeatureFlagRepresentable] {
        let toRemove: Set<CoreFeatureFlag> = []
        let all: Set<CoreFeatureFlag> = Set(CoreFeatureFlag.allCases)
        return Array(all.subtracting(toRemove))
    }
}
extension ModuleDependencies: CoreDependenciesResolver {
    func resolve() -> CoreDependencies {
        return coreDependencies
    }
}

// MARK: - Private
private extension ModuleDependencies {
    func registerExternalDependencies() {
        oldResolver.register(for: BizumModifierProtocol.self) { _ in
            return BizumModifier(dependencies: self)
        }
        oldResolver.register(for: SantanderKeyFirstLoginModifierProtocol.self) { _ in
            return SantanderKeyFirstLoginModifier(dependencies: self)
        }
        oldResolver.register(for: SKSecurityPersonalAreaModifierProtocol.self) { _ in
            return SKSecurityPersonalAreaModifier(dependencies: self)
        }
        oldResolver.register(for: SantanderKeyUpdateTokenModifierProtocol.self) { _ in
            return SKUpdateTokenModifier(dependencies: self)
        }
    }
}
