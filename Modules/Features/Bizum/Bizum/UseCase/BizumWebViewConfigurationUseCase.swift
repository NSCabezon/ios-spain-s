import CoreFoundationLib
import SANLibraryV3

protocol BizumWebViewConfigurationUseCaseProtocol: UseCase<Void, BizumWebViewConfigurationUseCaseOkOutput, StringErrorOutput> {}

final class BizumWebViewConfigurationUseCase: UseCase<Void, BizumWebViewConfigurationUseCaseOkOutput, StringErrorOutput> {
    
    private let provider: BSANManagersProvider
    
    init(dependenciesResolver: DependenciesResolver) {
        self.provider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<BizumWebViewConfigurationUseCaseOkOutput, StringErrorOutput> {
        let environmentResponse = self.provider.getBsanEnvironmentsManager().getCurrentEnvironment()
        guard environmentResponse.isSuccess(), let bsanEnvironment = try provider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData(), let bizumUrl = bsanEnvironment.urlBizumWeb else {
            return UseCaseResponse.error(StringErrorOutput(try environmentResponse.getErrorMessage()))
        }
        let token = try provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        let parameters = [
            "token": token,
            "bizum_app_version": "2"
        ]
        let closingUrl = "www.bancosantander.es"
        let configuration = BizumWebViewConfiguration(initialURL: bizumUrl,
                                                      bodyParameters: parameters,
                                                      closingURLs: [closingUrl],
                                                      webToolbarTitleKey: "toolbar_title_bizum",
                                                      pdfToolbarTitleKey: "toolbar_title_bizum")
        return .ok(BizumWebViewConfigurationUseCaseOkOutput(configuration: configuration))
    }
}

extension BizumWebViewConfigurationUseCase: BizumWebViewConfigurationUseCaseProtocol {}

struct BizumWebViewConfigurationUseCaseOkOutput {
    let configuration: WebViewConfiguration
}
