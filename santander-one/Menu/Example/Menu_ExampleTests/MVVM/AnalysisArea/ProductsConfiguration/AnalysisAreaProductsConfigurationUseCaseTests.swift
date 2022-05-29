//
//  AnalysisAreaProductsConfigurationUseCaseTests.swift
//  Menu_ExampleTests
//
//  Created by Miguel Ferrer Fornali on 21/3/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import CoreFoundationLib
import SANLegacyLibrary
import CoreTestData
import CoreDomain
@testable import Menu

final class AnalysisAreaProductsConfigurationUseCaseTests: XCTestCase {
    private lazy var externalDependencies = TestAnalysisAreaProductsConfigurationExternalDependenciesResolver(injector: mockDataInjector)
    private lazy var dependencies: TestAnalysisAreaProductsConfigurationDependenciesResolver = {
        let external = TestExternalDependencies(injector: self.mockDataInjector)
        return TestAnalysisAreaProductsConfigurationDependenciesResolver(injector: self.mockDataInjector, externalDependencies: externalDependencies)
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
    
    private var mockPreferencesInput: SetFinancialHealthPreferencesRepresentable {
        SetFinancialHealthPreferencesMock(preferencesProducts: [SetPreferencesProductRepresentableMock(preferencesProductType: .account, [
            SetPreferencesProductDataRepresentableMock(productId: "607d57a0219c3d2274230abd", productSelected: true),
            SetPreferencesProductDataRepresentableMock(productId: "607d57a0219c3d2274230abr", productSelected: false)
        ])])
    }
    private var mockPreferencesInputFail: SetFinancialHealthPreferencesRepresentable {
        SetFinancialHealthPreferencesMock(preferencesProducts: [SetPreferencesProductRepresentableMock(preferencesProductType: .account, [
            SetPreferencesProductDataRepresentableMock(productId: "", productSelected: true),
            SetPreferencesProductDataRepresentableMock(productId: "607d57a0219c3d2274230abr", productSelected: false)
        ])])
    }
    
    func test_Given_expectedFinancialHealthProductsMock_When_setFinancialHealthPreferencesUseCase_Then_receivedVoidValue() throws {
        let sut: SetAnalysisAreaPreferencesUseCase = dependencies.resolve()
        _ = sut.fetchSetFinancialPreferencesPublisher(preferences: mockPreferencesInput).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                XCTAssertTrue(true)
            case .failure:
                XCTFail()
            }
        }, receiveValue: { _ in
            XCTAssert(true)
        })
    }
    
    func test_Given_noExpectedFinancialHealthProductsMock_When_setFinancialHealthPreferencesUseCase_Then_getFailure() throws {
        let sut: SetAnalysisAreaPreferencesUseCase = dependencies.resolve()
        _ = sut.fetchSetFinancialPreferencesPublisher(preferences: mockPreferencesInputFail).sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                XCTFail()
            case .failure:
                XCTAssertTrue(true)
            }
        }, receiveValue: { _ in
            XCTFail()
        })
    }
}
