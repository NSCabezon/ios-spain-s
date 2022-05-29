//
//  AnalysisAreaHomeViewModelTests.swift
//  Menu_ExampleTests
//
//  Created by Luis Escámez Sánchez on 20/1/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import CoreDomain
import OpenCombine
import CoreTestData
import UnitTestCommons
@testable import Menu

final class AnalysisAreaHomeViewModelTests: XCTestCase {
    private lazy var dependenciesExternal = TestAnalysisAreaHomeExternalDependencies(injector: mockDataInjector)
    private lazy var dependencies: TestAnalysisAreaHomeDependenciesResolver = {
        return TestAnalysisAreaHomeDependenciesResolver(injector: self.mockDataInjector, externalDependencies: dependenciesExternal)
    }()
    private lazy var mockDataInjector: MockDataInjector = {
        let injector = MockDataInjector()
        injector.register(
            for: \.financialHealthData.summary, filename: "getFinancialHealthSummary")
        injector.register(
            for: \.financialHealthData.companies, filename: "getFinancialHealthCompaniesWithProducts")
        injector.register(
            for: \.financialHealthData.productsStatus, filename: "getFinancialHealthProductsStatus")
        injector.register(
            for: \.financialHealthData.updateProductStatus, filename: "getFinancialHealthProductsStatus")
        injector.register(
            for: \.financialHealthData.preferences, filename: "getFinancialHealthPreferences")
        injector.register(
            for: \.financialHealthData.categoryDetail, filename: "getFinancialHealthCategoryDetail")
        injector.register(
            for: \.financialHealthData.transactions, filename: "getFinancialHealthTransactions")
        return injector
    }()
    
    private let mockMessageInput = (LocalizedStylableText(text: "", styles: []), LocalizedStylableText(text: "", styles: []))
    
//    func test_When_CompaniesIsReceived_Then_CompaniesIsCalledProductsInfoIsSentAndProductsStatusIsCalled() throws {
//        let sut = AnalysisAreaViewModel(dependencies: dependencies)
//
//        let trigger = {
//            sut.viewDidLoad()
//        }
//
//        _ = try sut.state
//            .case(AnalysisAreaHomeState.productsInfoReceived)
//            .sinkAwait(beforeWait: trigger)
//
//        XCTAssertTrue(self.dependenciesExternal.companiesUseCaseSpy.companiesUseCaseCalled)
//        XCTAssertTrue(self.dependencies.productsStatusUseCaseSpy.productsStatusUseCaseCalled)
//    }

//    func test_When_CompaniesIsReceivedAndIsNotEmpty_Then_SummaryIsCalledAndSummaryIsSent() throws {
//        let sut = AnalysisAreaViewModel(dependencies: dependencies)
//
//        let trigger = {
//            sut.viewDidLoad()
//        }
//
//        _ = try sut.state
//            .case(AnalysisAreaHomeState.summaryReceived)
//            .sinkAwait(beforeWait: trigger)
//
//        XCTAssertTrue(self.dependenciesExternal.companiesUseCaseSpy.companiesUseCaseCalled)
//        XCTAssertTrue(self.dependencies.productsStatusUseCaseSpy.productsStatusUseCaseCalled)
//        XCTAssertTrue(self.dependencies.summaryUseCaseSpy.summaryUseCaseCalled)
//    }
    
    func test_When_goBack_Then_goBackIsCalled() throws {
        let sut = AnalysisAreaViewModel(dependencies: dependencies)
        
        sut.goBack()
        
        XCTAssertTrue(self.dependencies.homeCoordinatorSpy.goBackCalled)
    }
    
    func test_When_openPrivateMenu_Then_openPrivateMenuIsCalled() throws {
        let sut = AnalysisAreaViewModel(dependencies: dependencies)
        
        sut.openPrivateMenu()
        
        XCTAssertTrue(self.dependencies.homeCoordinatorSpy.openPrivateMenuCalled)
    }
    
    func test_When_didTapTooltip_Then_openTooltipIsCalled() throws {
        let sut = AnalysisAreaViewModel(dependencies: dependencies)
        
        sut.didTapToolTip(mockMessageInput)
        
        XCTAssertTrue(self.dependencies.homeCoordinatorSpy.openTooltipCalled)
    }
    
    func test_When_didTapChangeIntervalTime_Then_openChangeIntervalTimeIsCalled() throws {
        let sut = AnalysisAreaViewModel(dependencies: dependencies)
        
        sut.didTapChangeIntervalTime()
        
        XCTAssertTrue(self.dependencies.homeCoordinatorSpy.openChangeIntervalTimeCalled)
    }
    
    func test_When_didTapOpenConfiguration_Then_showProductsConfigurationIsCalled() throws {
        let sut = AnalysisAreaViewModel(dependencies: dependencies)
        
        sut.didTapOpenConfiguration()
        
        XCTAssertTrue(self.dependencies.homeCoordinatorSpy.showProductsConfigurationCalled)
    }
    
    func test_When_didTapAddNewBank_Then_openAddNewBankViewIsCalled() throws {
        let sut = AnalysisAreaViewModel(dependencies: dependencies)
        
        sut.didTapAddNewBank()
        
        XCTAssertTrue(self.dependencies.homeCoordinatorSpy.openAddNewBankViewCalled)
    }
}
