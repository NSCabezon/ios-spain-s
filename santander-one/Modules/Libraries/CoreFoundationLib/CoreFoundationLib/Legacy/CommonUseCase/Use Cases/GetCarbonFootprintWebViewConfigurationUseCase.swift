public class GetCarbonFootprintWebViewConfigurationUseCase: UseCase<GetCarbonFootprintWebViewConfigurationInput, GetCarbonFootprintWebViewConfigurationOkOutput, StringErrorOutput> {
    
    private let dependenciesResolver: DependenciesResolver
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    public override func executeUseCase(requestValues: GetCarbonFootprintWebViewConfigurationInput) throws -> UseCaseResponse<GetCarbonFootprintWebViewConfigurationOkOutput, StringErrorOutput> {
        let appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let initialUrl = appConfigRepository.getString(Constants.initialUrl) ?? ""
        let closeUrl = appConfigRepository.getString(Constants.closeUrl) ?? Constants.defaultClosingUrl
        let bodyParams = getBodyParams(requestValues,
                                       appConfigRepository: appConfigRepository)
        guard let params = bodyParams else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        let configuration = CarbonFootprintWebViewConfiguration(
            initialURL: initialUrl,
            bodyParameters: bodyParams,
            closingURLs: [closeUrl],
            webToolbarTitleKey: "menu_link_fingerPrint",
            pdfToolbarTitleKey: nil,
            pdfSource: .unknown,
            reloadSessionOnClose: false
        )
        let output = GetCarbonFootprintWebViewConfigurationOkOutput(configuration: configuration)
        return UseCaseResponse.ok(output)
    }
}

private extension GetCarbonFootprintWebViewConfigurationUseCase {
    func getBodyParams(_ requestValues: GetCarbonFootprintWebViewConfigurationInput,
                       appConfigRepository: AppConfigRepositoryProtocol) -> [String: String]? {
        let tokenId = requestValues.tokenId 
        let tokenData = requestValues.tokenData 
        let localAppConfig = dependenciesResolver.resolve(for: LocalAppConfig.self)
        let language = localAppConfig.language.rawValue.uppercased()
        let country = appConfigRepository.getString(Constants.BodyParams.santanderCountry)?.uppercased() ?? ""
        let entity = appConfigRepository.getString(Constants.BodyParams.santanderEntity) ?? ""
        guard tokenId.count > 0,
              tokenData.count > 0,
              language.count > 0,
              country.count > 0,
              entity.count > 0  else {
                  return nil
        }
        let bodyParams: [String: String] = [
            "Santander-Assertion-Validate": tokenId,
            "Santander-Data": tokenData,
            "Santander-Language": language,
            "Santander-Country": country,
            "Santander-Entity": entity,
            "Santander-Channel": Constants.Channel
        ]
        return bodyParams
    }
}

private struct Constants {
    static let initialUrl = "carbonFootprintUrl"
    static let closeUrl = "carbonFootprintCloseUrl"
    static let defaultClosingUrl = "https://www.bancosantander.es"
    static let Channel = "MOBILE"
    struct BodyParams {
        static let santanderCountry = "carbonFootprintCountry"
        static let santanderEntity = "carbonFootprintEntity"
    }
}

public struct GetCarbonFootprintWebViewConfigurationInput {
    public let tokenId: String
    public let tokenData: String
    public init(tokenId: String, tokenData: String) {
        self.tokenId = tokenId
        self.tokenData = tokenData
    }
}

public struct GetCarbonFootprintWebViewConfigurationOkOutput {
    public let configuration: WebViewConfiguration
}

struct CarbonFootprintWebViewConfiguration: WebViewConfiguration {
    let initialURL: String
    let httpMethod: HTTPMethodType = .post
    var bodyParameters: [String: String]?
    let closingURLs: [String]
    let webToolbarTitleKey: String?
    let pdfToolbarTitleKey: String?
    let pdfSource: PdfSource?
    let engine: WebViewConfigurationEngine = .webkit
    let isCachePdfEnabled: Bool = false
    let isFullScreenEnabled: Bool? = false
    var reloadSessionOnClose: Bool = false
}
