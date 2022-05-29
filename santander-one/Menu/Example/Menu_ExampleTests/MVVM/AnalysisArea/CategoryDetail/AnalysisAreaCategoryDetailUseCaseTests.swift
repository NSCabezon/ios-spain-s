//
//  AnalysisAreaCategoryDetailUseCaseTests.swift
//  Menu_ExampleTests
//
//  Created by Miguel Bragado Sánchez on 8/4/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import CoreTestData
import Menu

final class AnalysisAreaCategoryDetailUseCaseTests: XCTestCase {
    private lazy var external = TestAnalysisAreaCategoryDetailExternalDependenciesResolver(injector: self.mockDataInjector)
    private lazy var dependencies: TestAnalysisAreaCategoryDetailDependenciesResolver = {
        return TestAnalysisAreaCategoryDetailDependenciesResolver(injector: self.mockDataInjector, externalDependencies: external)
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
    
    func test_Given_getCategoryDetailUseCase_When_getCategoryDetailGetCall_Then_getNoEmptySubcategoryCollectionData() throws {
        let sut: GetAnalysisAreaCategoryDetailInfoUseCase = dependencies.resolve()
        let subcategories = try sut.fetchFinancialCategoryPublisher(categories: CategoryDetailMock()) .sinkAwait()
        XCTAssertFalse(subcategories.isEmpty)
    }
    
    func test_Given_getTransactionsUseCase_When_getTransactionsGetCall_Then_getNoEmptyTransactionCollectionData() throws {
        let sut: GetAnalysisAreaCategoryDetailInfoUseCase = dependencies.resolve()
        let subcategories = try sut.fetchFinancialCategoryPublisher(categories: CategoryDetailMock()) .sinkAwait()
        XCTAssertFalse(subcategories.isEmpty)
    }
}
