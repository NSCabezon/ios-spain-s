import CoreFoundationLib
import SANLegacyLibrary

public final class GetFractionablePaymentWebViewConfigurationUseCase: UseCase<GetFractionablePaymentWebViewConfigUseCaseInput, GetFractionablePaymentWebViewConfigUseCaseOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appConfigProtocol: AppConfigRepositoryProtocol

    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
   public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
       self.appConfigProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    public override func executeUseCase(requestValues: GetFractionablePaymentWebViewConfigUseCaseInput) throws -> UseCaseResponse<GetFractionablePaymentWebViewConfigUseCaseOkOutput, StringErrorOutput> {
        guard let initialUrl = appConfigProtocol.getString(FinancingConstants.webViewUrl) else {
            return .error(StringErrorOutput(""))
        }
        let defaultClosingUrl = "https://www.bancosantander.es"
        let titleBarKey = "toolbar_title_financingTransactions"
        let closingUrl: String = appConfigProtocol.getString(FinancingConstants.closeUrl) ?? defaultClosingUrl
        self.appConfigProtocol.getString(DirectMoneyConstants.appConfigPBIUrl)
        let token = try provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        var movementType = ""
        switch requestValues.paymentType {
        case .receipts:
            movementType = "R"
        case .transfers:
            movementType = "T"
        case .purchases:
            movementType = "C"
        case .creditCard:
            movementType = ""
        }
        let parameters: [String: String] = ["canal": "RML",
                                            "token": token,
                                            "operativa": "financiacion-recibos",
                                            "origen": "ios",
                                            "movementType": movementType]
        let configuration = FractionablePaymentWebViewConfiguration(initialURL: initialUrl,
                                                                    bodyParameters: parameters,
                                                                    closingURLs: [defaultClosingUrl],
                                                                    webToolbarTitleKey: titleBarKey,
                                                                    pdfToolbarTitleKey: nil,
                                                                    pdfSource: .unknown)
         return .ok(GetFractionablePaymentWebViewConfigUseCaseOkOutput(webViewConfiguration: configuration))
    }
}

public struct GetFractionablePaymentWebViewConfigUseCaseInput {
    public let paymentType: PaymentBoxType
    public init(type: PaymentBoxType) {
        self.paymentType = type
    }
}

public struct GetFractionablePaymentWebViewConfigUseCaseOkOutput {
     public let webViewConfiguration: WebViewConfiguration
}
