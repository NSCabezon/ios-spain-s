//
//  TestPublicMenuViewModel.swift
//  Menu_ExampleTests
//
//  Created by Juan Jose Acosta González on 20/12/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import Metal
import OpenCombine
import CoreFoundationLib
import UnitTestCommons
@testable import Menu

class TestPublicMenuViewModel: XCTestCase {
    
    lazy var dependencies: PublicMenuDependenciesResolverMock = {
        let external = PublicMenuSceneExternalDependenciesResolverMock()
        return PublicMenuDependenciesResolverMock(externalDepencies: external)
    }()
    
    func test_When_ViewDidLoad_Expect_GetAllInfoStarts() throws {
        let sut = PublicMenuViewModel(dependencies: dependencies)
        
        let trigger = {
            sut.viewDidLoad()
        }
        
        let _ = try sut.state
            .case { PublicMenuState.optionsLoaded }
            .sinkAwait(beforeWait: trigger)
        
        XCTAssertTrue(self.dependencies.comercialSegmentUseCase.filterUserCommercialSegmentElemCalled)
        XCTAssertTrue(self.dependencies.homeTipsUseCase.filterHomeTipsElemCalled)
        XCTAssertTrue(self.dependencies.publicMenuUseCase.fetchMenuConfigurationCalled)
    }
    
    func test_When_OpenURLActionIsSelected_Expect_OpenURLIsCalledInCoordinator() throws {
        let sut = PublicMenuViewModel(dependencies: dependencies)
        
        sut.didSelectAction(.openURL(url: "https://www.bancosantander.es"))
        
        XCTAssertTrue(self.dependencies.menuCoordinator.openURLCalled)
    }
    
    func test_When_GoToATMLocatorActionIsSelected_Expect_GoToATMIsCalledInCoordinator() throws {
        let sut = PublicMenuViewModel(dependencies: dependencies)
        
        sut.didSelectAction(.goToATMLocator)
        
        XCTAssertTrue(self.dependencies.menuCoordinator.goToAtmLocatorCalled)
    }
    
    func test_When_GoToStockholdersActionIsSelected_Expect_GoToStockholdersIsCalledInCoordinator() throws {
        let sut = PublicMenuViewModel(dependencies: dependencies)
        
        sut.didSelectAction(.goToStockholders)
        
        XCTAssertTrue(self.dependencies.menuCoordinator.goToStockholdersCalled)
    }
    
    func test_When_GoToOurProductsActionIsSelected_Expect_GoToOurProductsIsCalledInCoordinator() throws {
        let sut = PublicMenuViewModel(dependencies: dependencies)
        
        sut.didSelectAction(.goToOurProducts)
        
        XCTAssertTrue(self.dependencies.menuCoordinator.goToOurProductsCalled)
    }
    
    func test_When_ToggleMenuIsSelected_Expect_ToggleMenuIsCalledInCoordinator() throws {
        let sut = PublicMenuViewModel(dependencies: dependencies)
        
        sut.didSelectAction(.toggleSideMenu)
        
        XCTAssertTrue(self.dependencies.menuCoordinator.toggleSideMenuCalled)
    }
    
    func test_When_GoToHomeTipsActionIsSelected_Expect_GoToHomeTipsIsCalledInCoordinator() throws {
        let sut = PublicMenuViewModel(dependencies: dependencies)
        
        sut.didSelectAction(.goToHomeTips)
        
        XCTAssertTrue(self.dependencies.menuCoordinator.goToHomeTipsCalled)
    }
    
    func test_When_callPhoneActionIsSelected_Expect_OpenURLIsCalledInCoordinator() throws {
        let sut = PublicMenuViewModel(dependencies: dependencies)
        
        sut.didSelectAction(.callPhone(number: "611111111"))
        
        XCTAssertTrue(self.dependencies.menuCoordinator.openURLCalled)
    }
    
    func test_When_noneActionIsSelected_Expect_AnyActionIsCalledInCoordinator() throws {
        let sut = PublicMenuViewModel(dependencies: dependencies)
        
        sut.didSelectAction(.none)
        
        XCTAssertFalse(self.dependencies.menuCoordinator.openURLCalled)
        XCTAssertFalse(self.dependencies.menuCoordinator.goToAtmLocatorCalled)
        XCTAssertFalse(self.dependencies.menuCoordinator.goToStockholdersCalled)
        XCTAssertFalse(self.dependencies.menuCoordinator.goToOurProductsCalled)
        XCTAssertFalse(self.dependencies.menuCoordinator.goToHomeTipsCalled)
    }
}

class GetHomeTipsCountUseCaseSpy: GetHomeTipsCountUseCase {
    var filterHomeTipsElemCalled: Bool = false
    
    func filterHomeTipsElem(_ elementsToFilter: [[PublicMenuElementRepresentable]]) -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        filterHomeTipsElemCalled = true
        return Just(elementsToFilter).setFailureType(to: Never.self).eraseToAnyPublisher()
    }
}

class GetUserCommercialSegmentUseCaseSpy: GetUserCommercialSegmentUseCase {
    var filterUserCommercialSegmentElemCalled: Bool = false
    
    func filterUserCommercialSegmentElem(_ elementsToFilter: [[PublicMenuElementRepresentable]]) -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        filterUserCommercialSegmentElemCalled = true
        return Just(elementsToFilter).setFailureType(to: Never.self).eraseToAnyPublisher()
    }
}

class GetPublicMenuConfigurationUseCaseSpy: GetPublicMenuConfigurationUseCase {
    var fetchMenuConfigurationCalled: Bool = false
    
    func fetchMenuConfiguration() -> AnyPublisher<[[PublicMenuElementRepresentable]], Never> {
        fetchMenuConfigurationCalled = true
        return Just([]).setFailureType(to: Never.self).eraseToAnyPublisher()
    }
}



