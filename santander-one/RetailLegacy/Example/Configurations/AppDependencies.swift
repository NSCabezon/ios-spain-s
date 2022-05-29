//
//  AppDependencies.swift
//  RetailLegacy_Example
//
//  Created by Juan Carlos López Robles on 1/4/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import CoreFoundationLib
import Foundation
import RetailLegacy
import QuickSetup
import SANLegacyLibrary
import GlobalPosition
import SANServicesLibrary

final class AppDependencies {
    private let hostModule = HostModule()
    private let compilation = Compilation()
    let localAppConfig = LocalAppConfigMock()
    private let versionInfo = VersionInfoDTO(
        bundleIdentifier: Bundle.main.bundleIdentifier!,
        versionName: Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
    )

    
    private lazy var siriIntentsManager: SiriIntentsManagerHandler = {
        return SiriIntentsManagerHandler()
    }()
    
    private lazy var dataRepository: DataRepository = {
        return DataRepositoryBuilder(dependenciesResolver: dependencieEngine).build()
    }()


    lazy var dependencieEngine: DependenciesResolver & DependenciesInjector = {
        let dependencies = DependenciesDefault()
        dependencies.register(for: CompilationProtocol.self) { _ in
            return self.compilation
        }
        dependencies.register(for: VersionInfoDTO.self) { _ in
            return self.versionInfo
        }
        dependencies.register(for: HostsModuleProtocol.self) { resolver in
            return self.hostModule
        }
        dependencies.register(for: DataRepository.self) { resolver in
            return self.dataRepository
        }
        dependencies.register(for: EmmaTrackEventListProtocol.self) { _ in
            return EmmaTrackEventList()
        }
        dependencies.register(for: TrusteerRepositoryProtocol.self) { _ in
            return RAHandler.sharedInstance
        }
        dependencies.register(for: SiriAssistantProtocol.self) { _ in
            return self.siriIntentsManager
        }
        dependencies.register(for: LocalAppConfig.self) { _ in
            return self.localAppConfig
        }
        dependencies.register(for: TealiumCompilationProtocol.self) { _ in
            return TealiumCompilation()
        }
        dependencies.register(for: DepositModifier.self) { dependenciesResolver in
            return DepositDefaultModifier(dependenciesResolver: dependenciesResolver)
        }
        dependencies.register(for: FundModifier.self) { dependenciesResolver in
            return FundDefaultModifier(dependenciesResolver: dependenciesResolver)
        }
        dependencies.register(for: SharedDependenciesDelegate.self) { _ in
            return SharedDependenciesDelegateMock()
        }
        return dependencies
    }()
}
