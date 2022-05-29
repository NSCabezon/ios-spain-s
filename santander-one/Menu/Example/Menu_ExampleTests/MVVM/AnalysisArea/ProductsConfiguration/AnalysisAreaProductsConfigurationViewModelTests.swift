//
//  AnalysisAreaProductsConfigurationViewModelTests.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 25/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import CoreFoundationLib
import CoreDomain
import OpenCombine
import CoreTestData
import UnitTestCommons
@testable import Menu

final class AnalysisAreaProductsConfigurationViewModelTests: XCTestCase {
    private lazy var externalDependencies = TestAnalysisAreaProductsConfigurationExternalDependenciesResolver(injector: mockDataInjector)
    private lazy var dependencies: TestAnalysisAreaProductsConfigurationDependenciesResolver = {
        let external = TestExternalDependencies(injector: self.mockDataInjector)
        return TestAnalysisAreaProductsConfigurationDependenciesResolver(injector: self.mockDataInjector, externalDependencies: externalDependencies)
    }()
    private lazy var sut: AnalysisAreaProductsConfigurationViewModel = {
        return AnalysisAreaProductsConfigurationViewModel(dependencies: dependencies)
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
        return injector
    }()
    
    private let deleteBankInputMock = ProducListConfigurationOtherBanksRepresentableMock()
    
//    func test_When_didTapUpdateProducts_Then_CompaniesUseCaseIsCalled() throws {
//        let sut = AnalysisAreaProductsConfigurationViewModel(dependencies: dependencies)
//        
//        let trigger = {
//            sut.viewDidLoad()
//            sut.updateProducts()
//        }
//        
//        _ = try sut.state
//            .case(AnalysisAreaProductsConfigurationState.loadingCompanies)
//            .sinkAwait(beforeWait: trigger)
//
//        XCTAssertTrue(self.externalDependencies.companiesUseCase.companiesUseCaseCalled)
//    }
//    
//    func test_When_didTapContinue_Then_PreferencesUseCaseIsCalledAndGoBackIsCalled() throws {
//        let sut = AnalysisAreaProductsConfigurationViewModel(dependencies: dependencies)
//        
//        let trigger = {
//            sut.viewDidLoad()
//            sut.didTapContinue()
//        }
//        
//        _ = try sut.state
//            .case(AnalysisAreaProductsConfigurationState.hideLoader)
//            .sinkAwait(beforeWait: trigger)
//
//        XCTAssertTrue(self.dependencies.setPreferencesUseCaseSpy.setPreferencesUseCaseCalled)
//        XCTAssertTrue(self.dependencies.productsConfigurationCoordinatorSpy.goBackCalled)
//    }
//    
//    func test_When_didTapCloseButton_Then_backIsCalled() throws {
//        let sut = AnalysisAreaProductsConfigurationViewModel(dependencies: dependencies)
//        
//        sut.didTapCloseButton()
//
//        XCTAssertTrue(self.dependencies.productsConfigurationCoordinatorSpy.goBackCalled)
//    }
    
//    func test_When_didTapDeleteBank_Then_openDeleteOtherBankIsCalled() throws {
//        let sut = AnalysisAreaProductsConfigurationViewModel(dependencies: dependencies)
//
//        sut.didTapDeleteBank(deleteBankInputMock)
//
//        XCTAssertTrue(self.dependencies.productsConfigurationCoordinatorSpy.openDeleteOtherBankCalled)
//    }
}
