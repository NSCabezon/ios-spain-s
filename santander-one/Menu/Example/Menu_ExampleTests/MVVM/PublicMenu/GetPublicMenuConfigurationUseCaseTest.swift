//
//  GetPublicMenuConfigurationUseCaseTest.swift
//  Menu_ExampleTests
//
//  Created by alvola on 30/12/2021.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import CoreTestData
import CoreFoundationLib
@testable import Menu

final class GetPublicMenuConfigurationUseCaseTest: XCTestCase {
    private lazy var dependencies: TestPublicMenuDependenciesResolver = {
        let external = TestExternalDependencies(injector: self.mockDataInjector)
        return TestPublicMenuDependenciesResolver(externalDependencies: external)
    }()

    private lazy var mockDataInjector: MockDataInjector = {
        return MockDataInjector()
    }()
    
    private lazy var menuRepository: PublicMenuRepository = {
        return PublicMenuRepositoryMock()
    }()

    func test_When_ExistsRecoveryPasswordNode_Expect_RecoveryOptionIsEnabled() throws {
        let contains = try containsNode(.recoverPassword, with: ["recoverKeysUrl": "https://urlToTest"])
        XCTAssert(contains == true)
    }

    func test_When_ExistsRecoveryPasswordNode_Expect_RecoveryOptionIsEnabledAndContainsTheExpectedURL() throws {
        let nodeURL = "https://urlToTest"
        initAppConfigNodes(["recoverKeysUrl": nodeURL])
        let sut = DefaultGetPublicMenuConfigurationUseCase(dependencies: dependencies)
        
        let newElems = try sut.fetchMenuConfiguration().sinkAwait()
        var readedURL = ""
        newElems.forEach { conf in
            conf.forEach { optionsRow in
                if let top = optionsRow.top,
                   top.kindOfNode == .recoverPassword,
                   case let PublicMenuAction.openURL(url: url) = top.action {
                    readedURL = url
                } else if let bottom = optionsRow.bottom,
                          bottom.kindOfNode == .recoverPassword,
                          case let PublicMenuAction.openURL(url: url) = bottom.action {
                    readedURL = url
                }
            }
        }
        XCTAssert(readedURL == nodeURL)
    }

    func test_When_DoesntExistRecoveryPasswordNode_Expect_RecoveryOptionIsDisabled() throws {
        let contains = try containsNode(.recoverPassword, with: ["recoverKeysUrl": ""])
        XCTAssert(contains == false)
    }
    
    func test_When_ExistsMobileWebNode_Expect_MobileWebOptionIsEnabled() throws {
        let contains = try containsNode(.mobileWeb, with: ["webMovilUrl": "https://urlToTest"])
        XCTAssert(contains == true)
    }
    
    func test_When_DoesntExistMobileWebNode_Expect_MobileWebIsDisabled() throws {
        let contains = try containsNode(.mobileWeb, with: ["webMovilUrl": ""])
        XCTAssert(contains == false)
    }
    
    func test_When_ExistsGetMagicNode_Expect_GetMagicOptionIsEnabled() throws {
        let contains = try containsNode(.getMagic, with: ["obtainKeysUrl": "https://urlToTest"])
        XCTAssert(contains == true)
    }
    
    func test_When_DoesntExistGetMagicNode_Expect_GetMagicIsDisabled() throws {
        let contains = try containsNode(.getMagic, with: ["obtainKeysUrl": ""])
        XCTAssert(contains == false)
    }
    
    func test_When_ExistsBecomeClientNode_Expect_BecomeClientOptionIsEnabled() throws {
        let contains = try containsNode(.becomeClient, with: ["becomeClientUrl": "https://urlToTest"])
        XCTAssert(contains == true)
    }
    
    func test_When_DoesntExistBecomeClientNode_Expect_BecomeClientIsDisabled() throws {
        let contains = try containsNode(.becomeClient, with: ["becomeClientUrl": ""])
        XCTAssert(contains == false)
    }
    
    func test_When_ExistsStockholdersNode_Expect_StockholdersOptionIsEnabled() throws {
        let contains = try containsNode(.enableStockholders, with: ["enableStockholders": "true"])
        XCTAssert(contains == true)
    }
    
    func test_When_DoesntExistStockholdersNode_Expect_StockholdersIsDisabled() throws {
        let contains = try containsNode(.enableStockholders, with: ["enableStockholders": ""])
        XCTAssert(contains == false)
    }
}

private extension GetPublicMenuConfigurationUseCaseTest {
    func containsNode(_ node: KindOfPublicMenuNode, with appConfigInfo: [String: String]) throws -> Bool {
        initAppConfigNodes(appConfigInfo)
        let sut = DefaultGetPublicMenuConfigurationUseCase(dependencies: dependencies)
        
        let newElems = try sut.fetchMenuConfiguration().sinkAwait()
        
        return newElems.contains { conf in
            conf.contains { evaluateTypeOfNode($0.top, node) || evaluateTypeOfNode($0.bottom, node) }
        }
    }
    
    func evaluateTypeOfNode(_ elem: PublicMenuOptionRepresentable?, _ node: KindOfPublicMenuNode) -> Bool {
        guard let elem = elem else { return false }
        switch elem.type {
        case let .flipButton(principalItem: principalItem, secondaryItem: secondaryItem, time: _):
            return evaluateTypeOfNode(principalItem, node) || evaluateTypeOfNode(secondaryItem, node)
        case let .selectOptionButton(options: subOptions):
            return subOptions.contains(where: {
                $0.node == node
            })
        default:
            return elem.kindOfNode == node
        }
    }
    
    func initAppConfigNodes(_ nodes: [String: String]) {
        let appconfig = AppConfigDTOMock(defaultConfig: nodes)
        (dependencies.external as? TestExternalDependencies)?.injector.register(
            for: \.appConfigLocalData.getAppConfigLocalData,
            element: appconfig
        )
    }
}
