import CoreDomain
import SANSpainLibrary
import CoreDomain
import SANServicesLibrary
import CoreFoundationLib

 struct AdobeTargetDataRepository: AdobeTargetRepository {
    let environmentProvider: EnvironmentProvider
    let networkManager: NetworkClientManager
    let storage: Storage
    let requestSyncronizer: RequestSyncronizer
    let configurationRepository: ConfigurationRepository

    func getAdobeTargetOfferRequest(input: AdobeTargetOfferInputRepresentable) throws -> Result<AdobeTargetOfferRepresentable, Error> {
        guard let authToken: AuthenticationTokenDto = self.storage.get() else { return .failure(RepositoryError.unknown) }
        let inputDTO = AdobeTargetOfferQueryInputDTO(screenWidth: input.screenWidth ?? 0, screenHeight: input.screenHeight ?? 0)
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "iOS"
        let headers = ["User-Agent": appVersion, "Content-Type": "application/json"]
        let query =  ["groupId": input.groupId, "locationId": input.locationId]
        let url = self.environmentProvider.getEnvironment().restBaseUrl
        let request = RestSpainRequest(
            method: "POST",
            serviceName: "offers",
            url: url + "/api/v1/pulloffer/offers",
            headers: headers,
            query: query,
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
                AdobeTargetResponseInterceptor()
            ]
        )

        switch response {
        case .success(let resp):
            if let result = try? JSONDecoder().decode(AdobeTargetOfferDTO.self, from: resp.data) {
                return .success(result)
            }
        default:
            break
        }

        return .failure(RepositoryError.parsing)
    }
}

private extension AdobeTargetDataRepository {
    struct AdobeTargetError: Decodable {
        let moreInformation: String
        let httpMessage: String
    }

    struct AdobeTargetResponseInterceptor: NetworkResponseInterceptor {
        func interceptResponse(_ response: NetworkResponse) -> Result<NetworkResponse, Error> {
            guard let result = try? JSONDecoder().decode(AdobeTargetError.self, from: response.data) else {
                return .success(response)
            }
            let error = NSError(domain: "rest.response", code: Int(response.status), userInfo: [NSLocalizedDescriptionKey: result.httpMessage])
            return .failure(RepositoryError.error(error))
        }
    }
}
