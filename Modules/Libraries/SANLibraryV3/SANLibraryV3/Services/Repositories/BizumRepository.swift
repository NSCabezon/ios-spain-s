//
//  BizumDataRepository.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 11/5/21.
//

import SANSpainLibrary
import CoreDomain
import SANServicesLibrary
import CoreFoundationLib

struct BizumDataRepository: BizumRepository {
    
    let environmentProvider: EnvironmentProvider
    let networkManager: NetworkClientManager
    let storage: Storage
    let requestSyncronizer: RequestSyncronizer
    let configurationRepository: ConfigurationRepository
    
    func checkPayment(defaultXPAN: String) throws -> Result<BizumCheckPaymentRepresentable, Error> {
        guard let authToken: AuthenticationTokenDto = self.storage.get() else { return .failure(RepositoryError.unknown) }
        if let checkPayment = self.storage.get(BizumCheckPaymentDto.self) {
            return .success(checkPayment)
        }
        let url = self.environmentProvider.getEnvironment().restBaseUrl
        let request = RestSpainRequest(
            method: "POST",
            serviceName: "check-payment",
            url: url + "/payments/check-payment"
        )
        let mulmovUrls = self.configurationRepository[\.mulmovUrls] ?? []
        let response = try self.networkManager.request(
            request,
            requestInterceptors: [
                AuthorizationRestInterceptor(token: authToken.token),
                MulmovRestRequestInterceptor(urls: mulmovUrls),
                SantanderChannelRestInterceptor()
            ],
            responseInterceptors: [
                BizumResponseInterceptor()
            ]
        )
        return response
            .flatMap(to: BizumCheckPaymentDto.self)
            .map {
                guard ($0.xpan ?? "").isEmpty else { return $0 }
                return BizumCheckPaymentDto(checkpayment: $0, xpan: defaultXPAN)
            }
    }
}

private extension BizumDataRepository {
    
    struct BizumError: Decodable {
        let moreInformation: String
        let httpMessage: String
    }
    
    struct BizumResponseInterceptor: NetworkResponseInterceptor {
        func interceptResponse(_ response: NetworkResponse) -> Result<NetworkResponse, Error> {
            guard let result = try? JSONDecoder().decode(BizumError.self, from: response.data) else { return .success(response) }
            let error = NSError(domain: "rest.response", code: Int(response.status), userInfo: [NSLocalizedDescriptionKey: result.httpMessage])
            return .failure(RepositoryError.error(error))
        }
    }
}
