//
//  MockFinancialHealthRepository.swift
//  CoreTestData
//
//  Created by Luis Escámez Sánchez on 16/2/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public final class MockFinancialHealthRepository: FinancialHealthRepository {
    var summaryItems: [FinancialHealthSummaryItemRepresentable]
    var companies: [FinancialHealthCompanyRepresentable]
    var productsStatus: FinancialHealthProductsStatusRepresentable
    var updateProductStatus: FinancialHealthProductsStatusRepresentable
    var preferences: SetFinancialHealthPreferencesRepresentable
    var categoryDetail: [GetFinancialHealthSubcategoryRepresentable]
    var transactions: [GetFinancialHealthTransactionRepresentable]
    
    struct SomeError: LocalizedError {
        var errorDescription: String?
    }
    
    public init(mockDataInjector: MockDataInjector) {
        summaryItems = mockDataInjector
            .mockDataProvider
            .financialHealthData
            .summary
        
        companies = mockDataInjector
            .mockDataProvider
            .financialHealthData
            .companies
      
        productsStatus = mockDataInjector
            .mockDataProvider
            .financialHealthData
            .productsStatus
        
        updateProductStatus = mockDataInjector
            .mockDataProvider
            .financialHealthData
            .updateProductStatus
        
        preferences = mockDataInjector
            .mockDataProvider
            .financialHealthData
            .preferences
        
        categoryDetail = mockDataInjector
            .mockDataProvider
            .financialHealthData
            .categoryDetail
        
        transactions = mockDataInjector
            .mockDataProvider
            .financialHealthData
            .transactions
    }
    
    public func getFinancialSummary(products: GetFinancialHealthSummaryRepresentable) -> AnyPublisher<[FinancialHealthSummaryItemRepresentable], Error> {
        guard let products = products.products, products.count > 0 else {
            return Fail(error: SomeError()).eraseToAnyPublisher()
        }
        return Just(summaryItems)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func getFinancialCompaniesWithProducts() -> AnyPublisher<[FinancialHealthCompanyRepresentable], Error> {
        return Just(companies)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func getFinancialProductsStatus() -> AnyPublisher<FinancialHealthProductsStatusRepresentable, Error> {
        return Just(productsStatus)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func getFinancialUpdateProductStatus(productCode: String) -> AnyPublisher<FinancialHealthProductsStatusRepresentable, Error> {
        return Just(updateProductStatus)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func getFinancialPreferences(preferences: SetFinancialHealthPreferencesRepresentable) -> AnyPublisher<Void, Error> {
        if preferences.preferencesProducts?.contains(where: { $0.preferencesData?.contains(where: { $0.productId?.isEmpty ?? true }) ?? true }) ?? true {
            return Fail(error: SomeError())
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    public func deleteFinancialBank(bankCode: String) -> AnyPublisher<Void, Error> {
        if bankCode.isEmpty {
            return Fail(error: SomeError())
                .eraseToAnyPublisher()
        } else {
            return Just(())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
    }
    
    public func getFinancialCategoryDetailInfo(categories: GetFinancialHealthCategoryInputRepresentable) -> AnyPublisher<[GetFinancialHealthSubcategoryRepresentable], Error> {
        return Just(categoryDetail)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public func getFinancialtransactions(category: GetFinancialHealthTransactionsInputRepresentable) -> AnyPublisher<[GetFinancialHealthTransactionRepresentable], Error> {
        return Just(transactions)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
