import CoreFoundationLib
import SANLegacyLibrary

class GetMarketplaceWebViewConfigurationUseCase: UseCase<GetMarketplaceWebViewConfigurationInput, GetMarketplaceWebViewConfigurationOkOutput, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepository
    private let bsanManagersProvider: BSANManagersProvider
    private let defaultClosingUrl: String = "https://www.bancosantander.es"
    
    init(appConfigRepository: AppConfigRepository, bsanManagersProvider: BSANManagersProvider) {
        self.appConfigRepository = appConfigRepository
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override func executeUseCase(requestValues: GetMarketplaceWebViewConfigurationInput) throws -> UseCaseResponse<GetMarketplaceWebViewConfigurationOkOutput, StringErrorOutput> {
        guard let url: String = appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigMarketplaceUrl) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        let closingUrl: String = appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigMarketplaceCloseUrl) ?? defaultClosingUrl
        
        let token = try bsanManagersProvider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        
        var latitude = ""
        var longitude = ""
        
        if let latitudeUnwrapped = requestValues.latitude, let longitudeUnwrapped = requestValues.longitude {
            latitude = String(describing: latitudeUnwrapped)
            longitude =  String(describing: longitudeUnwrapped)
        }
        
        let parameters: [String: String] = ["canal": "MOV", "token": token, "latitude": latitude, "longitude": longitude]
        let configuration = MarketplaceWebViewConfiguration(initialURL: url,
                                                            bodyParameters: parameters,
                                                            closingURLs: [closingUrl],
                                                            webToolbarTitleKey: "toolbar_title_marketplace",
                                                            pdfToolbarTitleKey: nil,
                                                            pdfSource: .unknown)
        
        return UseCaseResponse.ok(GetMarketplaceWebViewConfigurationOkOutput(configuration: configuration))
    }
}

struct GetMarketplaceWebViewConfigurationInput {
    let latitude: Double?
    let longitude: Double?
}

struct GetMarketplaceWebViewConfigurationOkOutput {
    let configuration: WebViewConfiguration
}
