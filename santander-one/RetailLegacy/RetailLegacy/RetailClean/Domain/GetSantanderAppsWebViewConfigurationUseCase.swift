import CoreFoundationLib

class GetSantanderAppsWebViewConfigurationUseCase: UseCase<Void, GetSantanderAppsWebViewConfigurationUseCaseOkOutput, StringErrorOutput> {
    private let appRepository: AppRepository
    private let appConfigRepository: AppConfigRepository
    
    init(appRepository: AppRepository, appConfigRepository: AppConfigRepository) {
        self.appRepository = appRepository
        self.appConfigRepository = appConfigRepository
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<GetSantanderAppsWebViewConfigurationUseCaseOkOutput, StringErrorOutput> {
        let isPbUser = try appRepository.isPersistedUserPb().getResponseData() ?? false
        let node = isPbUser ? DomainConstant.appConfigSantanderAppsPBUrl : DomainConstant.appConfigSantanderAppsRetailUrl
        guard let url: String = appConfigRepository.getAppConfigNode(nodeName: node) else {
            return UseCaseResponse.error(StringErrorOutput(nil))
        }
        
        let parameters: [String: String] = ["bundleid": "es.bancosantander.apps"]
        let configuration = SantanderAppsWebViewConfiguration(initialURL: url, queryParameters: parameters, closingURLs: [], webToolbarTitleKey: "toolbar_title_appSantander", pdfToolbarTitleKey: nil)
        
        return UseCaseResponse.ok(GetSantanderAppsWebViewConfigurationUseCaseOkOutput(configuration: configuration))
    }
}

struct GetSantanderAppsWebViewConfigurationUseCaseOkOutput {
    let configuration: WebViewConfiguration
}
