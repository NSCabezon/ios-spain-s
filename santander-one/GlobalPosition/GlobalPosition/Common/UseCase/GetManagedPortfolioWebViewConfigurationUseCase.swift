//
//  GetManagedPortfolioWebViewConfigurationUseCase.swift
//  CommonUseCase
//
//  Created by Ali Ghanbari Dolatshahi on 10/1/22.
//

import CoreFoundationLib
import SANLegacyLibrary

final class GetPortfolioWebViewConfigurationUseCase: UseCase<GetPortfolioWebViewConfigurationUseCaseInput, GetPortfolioWebViewConfigurationUseCaseOutput, StringErrorOutput> {
    private let dependenciesResolver: DependenciesResolver
    private let appConfigProtocol: AppConfigRepositoryProtocol
    private let appRepository: AppRepositoryProtocol
    
    private lazy var provider: BSANManagersProvider = {
        return self.dependenciesResolver.resolve(for: BSANManagersProvider.self)
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.appRepository = self.dependenciesResolver.resolve(for: AppRepositoryProtocol.self)
        self.appConfigProtocol = self.dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
    }
    
    override func executeUseCase(requestValues: GetPortfolioWebViewConfigurationUseCaseInput) throws -> UseCaseResponse<GetPortfolioWebViewConfigurationUseCaseOutput, StringErrorOutput> {
        var title = ""
        var closingUrl = ""
        var url = ""
        if !requestValues.isManaged {
            guard
                let urlWeb = self.appConfigProtocol.getString(PortfoliosConstants.appConfigCustodyManagementUrlUrl)
            else {
                return .error(StringErrorOutput(""))
            }
            title = "toolbar_title_portfolioNoManaged"
            closingUrl = self.appConfigProtocol.getString(PortfoliosConstants.appConfigCustodyManagementCloseUrlCloseUrl) ?? PortfoliosConstants.defaultCloseUrl
            url = urlWeb
        } else {
            guard
                let urlWeb = self.appConfigProtocol.getString(PortfoliosConstants.appConfigDiscretionaryManagementUrl)
            else {
                return .error(StringErrorOutput(""))
            }
            title = "toolbar_title_portfolioManaged"
            closingUrl = self.appConfigProtocol.getString(PortfoliosConstants.appConfigDiscretionaryManagementCloseUrl) ?? PortfoliosConstants.defaultCloseUrl
            url = urlWeb
        }
       
        let token = try provider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        let language = appRepository.getCurrentLanguage().rawValue
        let portfolioId = requestValues.portfolio.dto.portfolioId ?? ""
        let parameters: [String: String] = ["canal": "MOV",
                                            "token": token,
                                            "language": language,
                                            "portfolioId": portfolioId]
        let configuration = PortfolioWebViewConfiguration(initialURL: url,
                                                            bodyParameters: parameters,
                                                            closingURLs: [closingUrl],
                                                            webToolbarTitleKey: title,
                                                            pdfToolbarTitleKey: nil,
                                                            pdfSource: nil)
        return .ok(GetPortfolioWebViewConfigurationUseCaseOutput(configuration: configuration))
    }
}

public struct GetPortfolioWebViewConfigurationUseCaseInput {
    let portfolio: PortfolioEntity
    let isManaged: Bool
}

struct GetPortfolioWebViewConfigurationUseCaseOutput {
    let configuration: WebViewConfiguration
}
