import SANLegacyLibrary

protocol FintechDataSourceProtocol: RestDataSource {
    func confirmWithAccessKey<T: Codable>(authenticationParams: FintechUserAuthenticationInputParams, userInfo: T) throws -> BSANResponse<FintechAccessConfimationResponseDTO>
}

public class FintechDataSource {
    let sanRestServices: SanRestServices
    private let bsanDataProvider: BSANDataProvider
    private let apiBasePath =  "/canales-digitales/internet/v1/"
    private let loginTppServiceName = "login-tpp-app"

    public init(sanRestServices: SanRestServices, bsanDataProvider: BSANDataProvider) {
        self.sanRestServices = sanRestServices
        self.bsanDataProvider = bsanDataProvider
    }
}

extension FintechDataSource: FintechDataSourceProtocol {
    func confirmWithAccessKey<T: Codable>(authenticationParams: FintechUserAuthenticationInputParams, userInfo: T) throws -> BSANResponse<FintechAccessConfimationResponseDTO> {
        let bsanEnvironment: BSANEnvironmentDTO = try self.bsanDataProvider.getEnvironment()
        guard let source = bsanEnvironment.fintechUrl else {
            return BSANErrorResponse(Meta.createKO())
        }
        guard let url = (source + self.apiBasePath + self.loginTppServiceName)
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return BSANErrorResponse(Meta.createKO("Invalid url"))
        }
        do {
            let response = try self.sanRestServices.executeRestCall(
                request: RestRequest(
                    serviceName: self.loginTppServiceName,
                    serviceUrl: url,
                    body: Body(bodyParam: userInfo),
                    queryParams: self.paramsDictionary(for: authenticationParams),
                    requestType: .post,
                    headers: [:],
                    responseEncoding: .utf8)
            )
            return try self.handleResponse(response)
        } catch let error as BSANUnauthorizedException {
            return BSANErrorResponse(Meta.createKO(error.responseValue ?? ""))
        } catch {
            return BSANErrorResponse(Meta.createKO(""))
        }
    }
}
private extension FintechDataSource {
    func handleResponse(_ response: Any?) throws -> BSANResponse<FintechAccessConfimationResponseDTO> {
        guard
            let response = response as? RestJSONResponse,
            let responseString = response.message else { return BSANErrorResponse(Meta.createKO("")) }
        switch response.httpCode {
        case 200:
            let decoder = JSONDecoder()
            guard let responseData = responseString.data(using: .utf8) else { return BSANErrorResponse(Meta.createKO("")) }
            let response = try decoder.decode(FintechAccessConfimationResponseDTO.self, from: responseData)
            return BSANOkResponse(response)
        case 400:
            return BSANErrorResponse(Meta.createKO(response.message ?? "NetworkException"))
        default:
            return BSANErrorResponse(Meta.createKO(""))
        }
    }
}

