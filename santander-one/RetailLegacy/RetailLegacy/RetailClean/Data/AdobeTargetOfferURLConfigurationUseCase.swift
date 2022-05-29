import CoreFoundationLib
import Foundation
import Menu
import SANLegacyLibrary

class AdobeTargetOfferURLConfigurationUseCase: UseCase<AdobeTargetOfferURLConfigurationUseCaseInput, AdobeTargetOfferURLConfigurationOkOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver

    public init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    private lazy var provider: BSANManagersProvider = {
        self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()

    override func executeUseCase(requestValues: AdobeTargetOfferURLConfigurationUseCaseInput) throws -> UseCaseResponse<AdobeTargetOfferURLConfigurationOkOutput, StringErrorOutput> {
        guard let openUrl = requestValues.viewModel.openURL,
              let closeURL = requestValues.viewModel.closeURL,
              let operative = requestValues.viewModel.operative,
              let channel = requestValues.viewModel.channel,
              let token = try? provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        else {
            return .error(StringErrorOutput(nil))
        }
        let parameters: [String: String] = ["canal": channel,
                                            "token": token,
                                            "operativa": operative]
        let adobeWebConfiguration = AdobeTargetOfferWebConfiguration(
            initialURL: openUrl,
            bodyParameters: parameters,
            closingURLs: [closeURL],
            webToolbarTitleKey: requestValues.viewModel.title,
            pdfToolbarTitleKey: requestValues.viewModel.pdfName)
        return .ok(AdobeTargetOfferURLConfigurationOkOutput(urlConfiguration: adobeWebConfiguration))
    }
}

struct AdobeTargetOfferURLConfigurationUseCaseInput {
    let viewModel: AdobeTargetOfferViewModel
}

struct AdobeTargetOfferURLConfigurationOkOutput {
    let urlConfiguration: AdobeTargetOfferWebConfiguration?
}
