import CoreFoundationLib
import SANLegacyLibrary

final class GetDirectMoneyWebViewConfigurationUseCase: UseCase<GetDirectMoneyWebViewConfigurationUseCaseInput, GetDirectMoneyWebViewConfigurationUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appConfigProtocol: AppConfigRepositoryProtocol
    
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appConfigProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: GetDirectMoneyWebViewConfigurationUseCaseInput) throws -> UseCaseResponse<GetDirectMoneyWebViewConfigurationUseCaseOkOutput, StringErrorOutput> {
        guard
            let formattedPAN = requestValues.card.formattedPAN,
            let url = self.appConfigProtocol.getString(DirectMoneyConstants.appConfigPBIUrl)
        else {
            return .error(StringErrorOutput(""))
        }        
        let closingUrl = self.appConfigProtocol.getString(DirectMoneyConstants.appConfigPBICloseUrl) ?? DirectMoneyConstants.defaultCloseUrl
        let token = try provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        let parameters: [String: String] = ["canal": "MOV",
                                            "token": token,
                                            "operativa": "pbi",
                                            "pan": formattedPAN]
        let configuration = DirectMoneyWebViewConfiguration(initialURL: url,
                                                            bodyParameters: parameters,
                                                            closingURLs: [closingUrl],
                                                            webToolbarTitleKey: "toolbar_title_directMoney",
                                                            pdfToolbarTitleKey: nil,
                                                            pdfSource: .unknown)
        return .ok(GetDirectMoneyWebViewConfigurationUseCaseOkOutput(configuration: configuration))
    }
}

public struct GetDirectMoneyWebViewConfigurationUseCaseInput {
    let card: CardEntity
}

struct GetDirectMoneyWebViewConfigurationUseCaseOkOutput {
    let configuration: WebViewConfiguration
}
