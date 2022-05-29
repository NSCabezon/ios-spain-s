//
//  AnalysisAreaHomeUseCaseTests.swift
//  Menu_ExampleTests
//
//  Created by Luis Escámez Sánchez on 16/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import XCTest
import QuickSetup
import CoreFoundationLib
import SANLegacyLibrary
import CoreTestData
import CoreDomain
@testable import Menu

final class GetAnalysisAreaHomeUseCaseTest: XCTestCase {
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
    
    private var mockUpdateProductStatusInput = "0049"
    
    func test_Given_getSummaryUseCase_When_getSummaryGetCall_Then_getNoEmptySummaryData() throws {
        let sut: GetAnalysisAreaSummaryUseCase = dependencies.resolve()
        let summary = try sut.fechFinancialSummaryPublisher(products: MockGetSummary()).sinkAwait()
        XCTAssertFalse(summary.isEmpty)
    }
    
    func test_Given_getCompaniesWithProductsUseCase_When_getFinancialCompaniesWithProductsGetCall_Then_getNoEmptySummaryData() throws {
        let sut: GetAnalysisAreaCompaniesWithProductsUseCase = dependencies.external.resolve()
        let companies = try sut.fechFinancialCompaniesPublisher().sinkAwait()
        XCTAssertFalse(companies.isEmpty)
    }
    
//    func test_Given_getProductsStatusUseCase_When_getProductsStatusGetCall_Then_getNoNilProductsStatusData() throws {
//        let sut: GetAnalysisAreaProductsStatusUseCase = dependencies.resolve()
//        let productsStatus = try sut.fechFinancialProductsStatusPublisher().sinkAwait()
//        XCTAssertFalse(productsStatus.entitiesData?.isEmpty ?? true)
//    }
    
    func test_Given_getUpdateProductUseCase_When_getUpdateProductGetCall_Then_getNoNilUpdateProductData() throws {
        let sut: GetAnalysisAreaUpdateProductStatusUseCase = dependencies.resolve()
        let productStatus = try sut.fechFinancialUpdateProductStatusPublisher(productCode: mockUpdateProductStatusInput).sinkAwait()
        XCTAssertFalse(productStatus.entitiesData?.isEmpty ?? true)
    }
}
