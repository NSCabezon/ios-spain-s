//
//  FinancialHealthDataRepository.swift
//  SANLibraryV3
//
//  Created by Luis Escámez Sánchez on 15/2/22.
//

import SANSpainLibrary
import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib
import SANServicesLibrary

public struct FinancialHealthDataRepository: FinancialHealthSpainRepository {
    let environmentProvider: EnvironmentProvider
    let networkManager: NetworkClientManager
    let storage: Storage
    let requestSyncronizer: RequestSyncronizer
    let configurationRepository: ConfigurationRepository
    
    public func getFinancialSummary(products: GetFinancialHealthSummaryRepresentable) -> AnyPublisher<[FinancialHealthSummaryItemRepresentable], Error> {
        return Future<[FinancialHealthSummaryItemRepresentable], Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    guard let authToken: AuthenticationTokenDto = self.storage.get() else {
                        throw RepositoryError.unknown
                    }
                    guard let inputDto = GetFinanciaHealthSummaryDTO(products) else {
                        throw RepositoryError.parsing
                    }
                    let request = RestSpainRequest(method: "POST", serviceName: "financialHealth_summary", url: baseUrl + basePath + "summary", body: inputDto, encoding: .json)
                    let result = try self.performRequest(request, tokenDTO: authToken).flatMap(to: [FinancialHealthSummaryItemDTO].self)
                    switch result {
                    case .success(let dto):
                        promise(.success(dto))
                    case .failure(let error):
                        dump(error)
                        promise(.failure(error))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func getFinancialCompaniesWithProducts() -> AnyPublisher<[FinancialHealthCompanyRepresentable], Error> {
        return Future<[FinancialHealthCompanyRepresentable], Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    guard let authToken: AuthenticationTokenDto = self.storage.get() else {
                        throw RepositoryError.unknown
                    }
                    let request = RestSpainRequest(method: "GET", serviceName: "financialHealth_companies", url: baseUrl + basePath + "products")
                    let result = try self.performRequest(request, tokenDTO: authToken).flatMap(to: [FinancialHealthCompanyDTO].self)
                    switch result {
                    case .success(let dto):
                        promise(.success(dto))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func getFinancialProductsStatus() -> AnyPublisher<FinancialHealthProductsStatusRepresentable, Error> {
        return Future<FinancialHealthProductsStatusRepresentable, Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    guard let authToken: AuthenticationTokenDto = self.storage.get() else {
                        throw RepositoryError.unknown
                    }
                    let request = RestSpainRequest(method: "GET", serviceName: "financialHealth_productsStatus", url: baseUrl + basePath + "products/status")
                    let result = try self.performRequest(request, tokenDTO: authToken).flatMap(to: FinancialHealthProductsStatusDTO.self)
                    switch result {
                    case .success(let dto):
                        promise(.success(dto))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func getFinancialUpdateProductStatus(productCode: String) -> AnyPublisher<FinancialHealthProductsStatusRepresentable, Error> {
        return Future<FinancialHealthProductsStatusRepresentable, Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    guard let authToken: AuthenticationTokenDto = self.storage.get() else {
                        throw RepositoryError.unknown
                    }
                    let request = RestSpainRequest(method: "GET", serviceName: "financialHealth_productsStatus", url: baseUrl + basePath + "products", query: ["code": productCode])
                    let result = try self.performRequest(request, tokenDTO: authToken).flatMap(to: FinancialHealthProductsStatusDTO.self)
                    switch result {
                    case .success(let dto):
                        promise(.success(dto))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func getFinancialPreferences(preferences: SetFinancialHealthPreferencesRepresentable) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    guard let authToken: AuthenticationTokenDto = self.storage.get() else {
                        throw RepositoryError.unknown
                    }
                    guard let inputDto = SetFinancialHealthPreferencesInputDTO(preferences) else {
                        throw RepositoryError.parsing
                    }
                    let request = RestSpainRequest(method: "PUT", serviceName: "financialHealth_preferences", url: baseUrl + basePath + "preferences", body: inputDto, encoding: .json)
                    let result = try self.performRequest(request, tokenDTO: authToken)
                    switch result {
                    case .success(_):
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func deleteFinancialBank(bankCode: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    guard let authToken: AuthenticationTokenDto = self.storage.get() else {
                        throw RepositoryError.unknown
                    }
                    let request = RestSpainRequest(method: "DELETE", serviceName: "financialHealth_deleteBank", url: baseUrl + basePath + "aggregation/\(bankCode)")
                    let result = try self.performRequest(request, tokenDTO: authToken)
                    switch result {
                    case .success:
                        promise(.success(()))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func getFinancialCategoryDetailInfo(categories: GetFinancialHealthCategoryInputRepresentable) -> AnyPublisher<[GetFinancialHealthSubcategoryRepresentable], Error> {
        return Future<[GetFinancialHealthSubcategoryRepresentable], Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    guard let authToken: AuthenticationTokenDto = self.storage.get() else {
                        throw RepositoryError.unknown
                    }
                    guard let inputDto = GetFinancialHealthCategoryInputDTO(categories) else {
                        throw RepositoryError.parsing
                    }
                    let request = RestSpainRequest(method: "POST", serviceName: "financialHealth_category", url: baseUrl + basePath + "summary/category", body: inputDto, encoding: .json)
                    let result = try self.performRequest(request, tokenDTO: authToken).flatMap(to: [GetFinancialHealthSubcategoryDTO].self)
                    switch result {
                    case .success(let dto):
                        promise(.success(dto))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    public func getFinancialtransactions(category: GetFinancialHealthTransactionsInputRepresentable) -> AnyPublisher<[GetFinancialHealthTransactionRepresentable], Error> {
        return Future<[GetFinancialHealthTransactionRepresentable], Error> { promise in
            Async(queue: .global(qos: .default)) {
                do {
                    guard let authToken: AuthenticationTokenDto = self.storage.get() else {
                        throw RepositoryError.unknown
                    }
                    guard let inputDto = GetFinancialHealthTransactionsInputDTO(category) else {
                        throw RepositoryError.parsing
                    }
                    let request = RestSpainRequest(method: "POST", serviceName: "financialHealth_transactions", url: baseUrl + basePath + "category/transactions", body: inputDto, encoding: .json)
                    let result = try self.performRequest(request, tokenDTO: authToken).flatMap(to: [GetFinancialHealthTransactionDTO].self)
                    switch result {
                    case .success(let dto):
                        promise(.success(dto))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}

private extension FinancialHealthDataRepository {
    
    var baseUrl: String {
        self.environmentProvider.getEnvironment().restBaseUrl
    }
    
    var basePath: String {
        return "/api/v1/pfm/"
    }
    
    func performRequest(_ request: NetworkRequest, tokenDTO: AuthenticationTokenDto) throws ->  Result<NetworkResponse, Error> {
        let mulmovUrls = self.configurationRepository[\.mulmovUrls] ?? []
        return try self.networkManager.request(
            request,
            requestInterceptors: [
                ContentTypeRestInterceptor(type: .json),
                AuthorizationRestInterceptor(token: tokenDTO.token),
                MulmovRestRequestInterceptor(urls: mulmovUrls),
                SantanderChannelRestInterceptor()
            ],
            responseInterceptors: [
                FinancialHealthResponseInterceptor()
            ]
        )
    }
}

//MARK: - Interceptor stuff
private extension FinancialHealthDataRepository {
    
    struct FinancialHealthError: Decodable {
        let status: String
        let code: Int
        let message: String
        let developerMessage: String
    }
    
    struct FinancialHealthResponseInterceptor: NetworkResponseInterceptor {
        func interceptResponse(_ response: NetworkResponse) -> Result<NetworkResponse, Error> {
            guard let result = try? JSONDecoder().decode(FinancialHealthError.self, from: response.data) else { return .success(response) }
            let error = NSError(domain: "rest.response", code: Int(response.status), userInfo: [NSLocalizedDescriptionKey: result.developerMessage])
            return .failure(RepositoryError.error(error))
        }
    }
}
