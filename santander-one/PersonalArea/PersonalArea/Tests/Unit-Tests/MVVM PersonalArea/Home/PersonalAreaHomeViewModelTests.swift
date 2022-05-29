//
//  PersonalAreaHomeViewModelTests.swift
//  Cards-Unit-Tests
//
//  Created by alvola on 20/4/22.
//

import XCTest
import CoreTestData
import CoreFoundationLib
import OpenCombine
import UnitTestCommons
@testable import PersonalArea

class PersonalAreaHomeViewModelTests: XCTestCase {
    
    lazy var dependencies: TestPersonalAreaHomeDependencies = {
        let external = TestExternalDependencies(injector: self.mockDataInjector,
                                                oldDependenciesResolver: self.oldDependencies)
        return TestPersonalAreaHomeDependencies(injector: self.mockDataInjector, externalDependencies: external)
    }()
    
    lazy var oldDependencies: DependenciesResolver = {
        let dependencies = DependenciesDefault(father: nil)
        dependencies.register(for: UseCaseHandler.self) { _ in
            return UseCaseHandler()
        }
        dependencies.register(for: AppConfigRepositoryProtocol.self) { _ in
            return MockAppConfigRepository(mockDataInjector: self.mockDataInjector)
        }
        return dependencies
    }()
    
    lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.gpData.getGlobalPositionMock,
            filename: "obtenerPosGlobal")
        return injector
    }()

    func test_given_globalPositionUsername_when_moduleStarts_then_usernameIsPublished() throws {
        let appConfig = AppConfigDTOMock(defaultConfig: [:])
        self.mockDataInjector.mockDataProvider.appConfigLocalData.getAppConfigLocalData = appConfig
        let sut = PersonalAreaHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        sut.viewBecomeActive()
        let username = try sut.state
            .case(PersonalAreaHomeState.usernameLoaded)
            .sinkAwait()
        XCTAssert(!(username ?? "").isEmpty)
    }
    
    func test_given_defaultConfiguration_when_moduleStarts_then_loadDefaultFields() throws {
        let appConfig = AppConfigDTOMock(defaultConfig: [PersonalAreaConstants.isPersonalAreaSecuritySettingEnabled: "true"])
        self.mockDataInjector.mockDataProvider.appConfigLocalData.getAppConfigLocalData = appConfig
        
        let sut = PersonalAreaHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        sut.viewBecomeActive()
        
        let fields = try sut.state
            .case(PersonalAreaHomeState.homeFieldsLoaded)
            .sinkAwait()
        XCTAssert(!fields.isEmpty)
    }
    
    func test_given_isSecurityEnabled_when_moduleStarts_fieldsContainsSecurityCell() throws {
        let appConfig = AppConfigDTOMock(defaultConfig: [PersonalAreaConstants.isPersonalAreaSecuritySettingEnabled: "true"])
        self.mockDataInjector.mockDataProvider.appConfigLocalData.getAppConfigLocalData = appConfig
        
        let sut = PersonalAreaHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        sut.viewBecomeActive()
        
        let fields = try sut.state
            .case(PersonalAreaHomeState.homeFieldsLoaded)
            .sinkAwait()
        XCTAssert(fields.contains(where: { $0.goToSection == PersonalAreaSection.security }))
    }
    
    func test_given_isSecurityDisabled_when_moduleStarts_fieldsContainsSecurityCell() throws {
        let appConfig = AppConfigDTOMock(defaultConfig: [PersonalAreaConstants.isPersonalAreaSecuritySettingEnabled: "false"])
        self.mockDataInjector.mockDataProvider.appConfigLocalData.getAppConfigLocalData = appConfig
        
        let sut = PersonalAreaHomeViewModel(dependencies: dependencies)
        sut.viewDidLoad()
        sut.viewBecomeActive()
        
        let fields = try sut.state
            .case(PersonalAreaHomeState.homeFieldsLoaded)
            .sinkAwait()
        XCTAssert(!fields.contains(where: { $0.goToSection == PersonalAreaSection.security }))
    }
}
