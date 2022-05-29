//
//  QuickSetup.swift
//  QuickSetup
//
//  Created by Jose Carlos Estela Anguita on 26/09/2019.
//  Copyright © 2019 Jose Carlos Estela Anguita. All rights reserved.
//

import SANLegacyLibrary
import CoreFoundationLib
import SANLibraryV3
import QuickSetup
import Foundation
import CoreTestData

public class QuickSetupForSpainLibrary {
    let mockDataInjector = MockDataInjector()
    private lazy var versionInfo: VersionInfoDTO = {
        return VersionInfoDTO(
            bundleIdentifier: Bundle.main.bundleIdentifier ?? "",
            versionName: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        )
    }()
    private lazy var dataRepository: DataRepository = {
        return DataRepositoryBuilder(appInfo: versionInfo).build()
    }()
    private lazy var targetProvider: TargetProvider = {
        let webServicesUrlProvider = WebServicesUrlProviderImpl(bsanDataProvider: bsanDataProvider)
        webServicesUrlProvider.setUrlsForMulMov(["sanesp-pre.pru.bsch"])
        return TargetProviderImpl(
            webServicesUrlProvider: webServicesUrlProvider,
            bsanDataProvider: bsanDataProvider
        )
    }()
    public lazy var managersProvider = {
        return  BSANManagersProviderBuilder(
            bsanDataProvider: BSANDataProvider(
                dataRepository: dataRepository,
                appInfo: versionInfo
            ),
            targetProvider: targetProvider
        ).build()
    }()
    public lazy var bsanDataProvider: BSANDataProvider = {
        return BSANDataProvider(dataRepository: dataRepository, appInfo: versionInfo)
    }()
    
    public init(environment: BSANEnvironmentDTO, user: User) {
        BSANLogger.setBSANLogger(self)
        targetProvider.webServicesUrlProvider.setUrlsForMulMov([
            "sanesp-pre.pru.bsch"
        ])
        self.setEnviroment(environment)
        self.doLogin(withUser: user)
    }
    
    public func setDemoAnswers(_ answers: [String: Int]) {
        self.targetProvider.getDemoInterpreter().setAnswers(answers)
    }
}

public extension QuickSetupForSpainLibrary {
    func setEnviroment(_ environment: BSANEnvironmentDTO) {
        _ = managersProvider.getBsanEnvironmentsManager().setEnvironment(bsanEnvironment: environment)
    }
    
    func isDemo(_ username: String?) -> Bool {
        if let username = username {
            return targetProvider.getDemoInterpreter().isDemoUser(userName: username)
        }
        return false
    }
    
    func getGlobalPosition() -> GlobalPositionRepresentable? {
        let response = try? self.managersProvider.getBsanPGManager().getGlobalPosition()
        _ = try? self.managersProvider.getBsanCardsManager().loadCardSuperSpeed(pagination: nil)
        let globalPosition = try? response?.getResponseData()
        let cardsData = try? self.managersProvider.getBsanCardsManager().getCardsDataMap().getResponseData()
        let temporallyInactiveCards = try? self.managersProvider.getBsanCardsManager().getTemporallyInactiveCardsMap().getResponseData()
        let inactiveCards = try? self.managersProvider.getBsanCardsManager().getInactiveCardsMap().getResponseData()
        _ = try? self.managersProvider.getBsanSignatureManager().loadCMCSignature()
        _ = try? self.managersProvider.getBsanSendMoneyManager().loadCMPSStatus()
        let cardBalances = try? self.managersProvider.getBsanCardsManager().getCardsBalancesMap().getResponseData()
        return globalPosition.map {
            GlobalPositionMock($0, cardsData: cardsData ?? [:], temporallyOffCards: temporallyInactiveCards ?? [:], inactiveCards: inactiveCards ?? [:], cardBalances: cardBalances ?? [:])
        }
    }
    
    func getGlobalPositionMock() -> GlobalPositionMock? {
        let response = try? self.managersProvider.getBsanPGManager().getGlobalPosition()
        guard let globalPosition = try? response?.getResponseData() else { return nil }
        _ = try? self.managersProvider.getBsanCardsManager().loadCardSuperSpeed(pagination: nil)
        let cardsData = try? self.managersProvider.getBsanCardsManager().getCardsDataMap().getResponseData()
        let temporallyInactiveCards = try? self.managersProvider.getBsanCardsManager().getTemporallyInactiveCardsMap().getResponseData()
        let inactiveCards = try? self.managersProvider.getBsanCardsManager().getInactiveCardsMap().getResponseData()
        _ = try? self.managersProvider.getBsanSignatureManager().loadCMCSignature()
        _ = try? self.managersProvider.getBsanSendMoneyManager().loadCMPSStatus()
        let cardBalances = try? self.managersProvider.getBsanCardsManager().getCardsBalancesMap().getResponseData()
        return GlobalPositionMock(globalPosition, cardsData: cardsData ?? [:], temporallyOffCards: temporallyInactiveCards ?? [:], inactiveCards: inactiveCards ?? [:], cardBalances: cardBalances ?? [:])
    }
    
    func doLogin(withUser user: User) {
        do {
            let password = "14725836"
            let response = try self.managersProvider
                .getBsanAuthManager()
                .authenticate(login: user.user, magic: password, loginType: .N, isDemo: self.isDemo(user.user))
            guard response.isSuccess() else {
                debugPrint("Can not do login with user: \(user)")
                return
            }
            _ = try self.managersProvider.getBsanPGManager().loadGlobalPosition(onlyVisibleProducts: true, isPB: user.isPB)
        } catch {
            debugPrint("Something going wrong when try to login with user: \(user)")
        }
    }
}

extension QuickSetupForSpainLibrary: ServicesProvider {
    public func registerDependencies(in dependencies: DependenciesInjector & DependenciesResolver) {
        for serviceInjector in dependencies.resolve(for: [CustomServiceInjector].self) {
            serviceInjector.inject(injector: self.mockDataInjector)
        }
        dependencies.register(for: BSANManagersProvider.self) { _ in
            return self.managersProvider
        }
        dependencies.register(for: GlobalPositionRepresentable.self) { _ in
            return self.getGlobalPosition()!
        }
        dependencies.register(for: GlobalPositionWithUserPrefsRepresentable.self) { resolver in
            let globalPosition = resolver.resolve(for: GlobalPositionRepresentable.self)
            return GlobalPositionPrefsMergerEntity(resolver: resolver, globalPosition: globalPosition, saveUserPreferences: true)
        }
        
        MockRepositoryManager(dependencies: dependencies, mockDataInjector: mockDataInjector).registerDependencies()
    }
}

extension QuickSetupForSpainLibrary: BSANLog {
    public func v(_ tag: String, _ message: String) {
        print(message)
    }
    
    public func v(_ tag: String, _ object: AnyObject) {
        print(object)
    }
    
    public func i(_ tag: String, _ message: String) {
        print(message)
    }
    
    public func i(_ tag: String, _ object: AnyObject) {
        print(object)
    }
    
    public func d(_ tag: String, _ message: String) {
        print(message)
    }
    
    public func d(_ tag: String, _ object: AnyObject) {
        print(object)
    }
    
    public func e(_ tag: String, _ message: String) {
        print(message)
    }
    
    public func e(_ tag: String, _ object: AnyObject) {
        print(object)
    }
}
