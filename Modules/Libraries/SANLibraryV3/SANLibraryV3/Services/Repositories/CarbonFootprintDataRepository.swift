import CoreDomain
import SANSpainLibrary
import CoreDomain
import SANServicesLibrary
import CoreFoundationLib

struct CarbonFootprintDataRepository: SpainCarbonFootprintRepository {
    let environmentProvider: EnvironmentProvider
    let networkManager: NetworkClientManager
    let configurationRepository: ConfigurationRepository
    let storage: Storage
    
    func getCarbonFootprintIdentificationToken(input: CarbonFootprintIdInputRepresentable) throws -> Result<CarbonFootprintTokenRepresentable, Error> {
        guard let authToken: AuthenticationTokenDto = self.storage.get() else { return .failure(RepositoryError.unknown) }
        let headers = ["X-Santander-Channel": "RML", "X-ClientId": "MULMOV", "Content-Type": "application/json"]
        let url = self.environmentProvider.getEnvironment().restBaseUrl
        let inputDTO = CarbonFootprintIdInputDTO(realmId: input.realmId ?? "")
        let request = RestSpainRequest(
            method: "POST",
            serviceName: "tokens",
            url: url + "/api/v1/carbon-footprint/tokens",
            headers: headers,
            body: inputDTO,
            encoding: .json
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
                CarbonFootprintIdResponseInterceptor()
            ]
        )

        if case .success(let resp) = response {
            if let result = try? JSONDecoder().decode(CarbonFootprintTokenDTO.self, from: resp.data) {
                return .success(result)
            }
        }
        return .failure(RepositoryError.parsing)
    }
    
    func getCarbonFootprintDataToken(input: CarbonFootprintDataInputRepresentable) throws -> Result<CarbonFootprintTokenRepresentable, Error> {
        guard let authToken: AuthenticationTokenDto = self.storage.get() else { return .failure(RepositoryError.unknown) }
        let headers = ["X-Santander-Channel": "RML", "X-ClientId": "MULMOV", "Content-Type": "application/json"]
        let url = self.environmentProvider.getEnvironment().restBaseUrl
        let inputDTO = CarbonFootprintDataInputDTO(firstName: input.firstName ?? "",
                                                   lastName: input.lastName ?? "",
                                                   contract: input.contract ?? "")
        let request = RestSpainRequest(
            method: "POST",
            serviceName: "data-tokens",
            url: url + "/api/v1/carbon-footprint/data-tokens",
            headers: headers,
            body: inputDTO,
            encoding: .json
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
                CarbonFootprintIdResponseInterceptor()
            ]
        )

        if case .success(let resp) = response {
            if let result = try? JSONDecoder().decode(CarbonFootprintTokenDTO.self, from: resp.data) {
                return .success(result)
            }
        }
        return .failure(RepositoryError.parsing)
    }
}

private extension CarbonFootprintDataRepository {
    struct CarbonFootprintIdError: Decodable {
        let moreInformation: String
        let httpMessage: String
    }

    struct CarbonFootprintIdResponseInterceptor: NetworkResponseInterceptor {
        func interceptResponse(_ response: NetworkResponse) -> Result<NetworkResponse, Error> {
            guard let result = try? JSONDecoder().decode(CarbonFootprintIdError.self, from: response.data) else {
                return .success(response)
            }
            let error = NSError(domain: "rest.response", code: Int(response.status), userInfo: [NSLocalizedDescriptionKey: result.httpMessage])
            return .failure(RepositoryError.error(error))
        }
    }
}
