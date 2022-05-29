//
//  FinancialHealthRepository.swift
//  CoreDomain
//
//  Created by Luis Escámez Sánchez on 15/2/22.
//

import OpenCombine

public protocol FinancialHealthRepository {
    func getFinancialSummary(products: GetFinancialHealthSummaryRepresentable) -> AnyPublisher<[FinancialHealthSummaryItemRepresentable], Error>
    func getFinancialCompaniesWithProducts() -> AnyPublisher<[FinancialHealthCompanyRepresentable], Error>
    func getFinancialProductsStatus() -> AnyPublisher<FinancialHealthProductsStatusRepresentable, Error>
    func getFinancialUpdateProductStatus(productCode: String) -> AnyPublisher<FinancialHealthProductsStatusRepresentable, Error>
    func getFinancialPreferences(preferences: SetFinancialHealthPreferencesRepresentable) -> AnyPublisher<Void, Error>
    func deleteFinancialBank(bankCode: String) -> AnyPublisher<Void, Error>
    func getFinancialCategoryDetailInfo(categories: GetFinancialHealthCategoryInputRepresentable) -> AnyPublisher<[GetFinancialHealthSubcategoryRepresentable], Error>
    func getFinancialtransactions(category: GetFinancialHealthTransactionsInputRepresentable) -> AnyPublisher<[GetFinancialHealthTransactionRepresentable], Error>
}
