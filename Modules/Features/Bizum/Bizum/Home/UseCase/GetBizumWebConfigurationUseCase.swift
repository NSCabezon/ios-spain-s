import Foundation
import CoreFoundationLib
import SANLibraryV3

class GetBizumWebConfigurationUseCase: UseCase<GetBizumWebConfigurationUseCaseInput, GetBizumWebConfigurationUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let provider: BSANManagersProvider
    
    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.provider = self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }
    
    override func executeUseCase(requestValues: GetBizumWebConfigurationUseCaseInput) throws -> UseCaseResponse<GetBizumWebConfigurationUseCaseOkOutput, StringErrorOutput> {
        let environmentResponse = self.provider.getBsanEnvironmentsManager().getCurrentEnvironment()
        guard environmentResponse.isSuccess(), let bsanEnvironment = try provider.getBsanEnvironmentsManager().getCurrentEnvironment().getResponseData(), let bizumUrl = bsanEnvironment.urlBizumWeb else {
            return UseCaseResponse.error(StringErrorOutput(try environmentResponse.getErrorMessage()))
        }
        let parameters = try self.generateParameters(with: requestValues.type)
        let closingUrl = "www.bancosantander.es"
        let configuration = BizumWebViewConfiguration(initialURL: bizumUrl,
                                                      bodyParameters: parameters,
                                                      closingURLs: [closingUrl],
                                                      webToolbarTitleKey: "toolbar_title_bizum",
                                                      pdfToolbarTitleKey: "toolbar_title_bizum")
        return UseCaseResponse.ok(GetBizumWebConfigurationUseCaseOkOutput(configuration: configuration))
    }
}

private extension GetBizumWebConfigurationUseCase {
    func generateParameters(with type: BizumWebViewType) throws -> [String: String] {
        let token = try self.provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        var parameters = [
            "token": token,
            "bizum_app_version": "2"
        ]
        switch type {
        case .donation:
            parameters["operation"] = "sendONG"
        case .qrCode:
            parameters["operation"] = "qrCode"
        case .settings:
            parameters["operation"] = "settings"
        }
        return parameters
    }
}

public enum BizumWebViewType {
    case qrCode, donation, settings
}

struct GetBizumWebConfigurationUseCaseInput {
    let type: BizumWebViewType
}

struct GetBizumWebConfigurationUseCaseOkOutput {
    let configuration: WebViewConfiguration
}
