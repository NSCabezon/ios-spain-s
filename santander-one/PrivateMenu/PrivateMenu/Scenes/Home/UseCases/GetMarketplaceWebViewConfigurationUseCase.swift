//
//  GetMarketplaceWebViewConfigurationUseCase.swift
//  PrivateMenu
//
//  Created by Daniel Gómez Barroso on 29/12/21.
//

import OpenCombine
import CoreDomain
import CoreFoundationLib
import RxCombine

public protocol GetMarketplaceWebViewConfigurationUseCase {
    func fetchWebViewConfiguration(location: (Double, Double)?) -> AnyPublisher<WebViewConfiguration, Error>
}

struct DefaultGetMarketplaceWebViewConfigurationUseCase {
    private let repository: MenuRepository
    private let appConfigRepository: AppConfigRepositoryProtocol
    private let defaultClosingUrl: String = "https://www.bancosantander.es"
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        self.repository = dependencies.resolve()
        self.appConfigRepository = dependencies.resolve()
    }
}

extension DefaultGetMarketplaceWebViewConfigurationUseCase: GetMarketplaceWebViewConfigurationUseCase {
    struct GetUrlMissingError: Error {}
    
    func fetchWebViewConfiguration(location: (Double, Double)?) -> AnyPublisher<WebViewConfiguration, Error> {
        let urlPublisher: AnyPublisher<String?, Never> = self.appConfigRepository.value(for: "marketplaceUrl")
        let urlPublisherWithError: AnyPublisher<String, Error> = urlPublisher
            .setFailureType(to: Error.self)
            .tryMap() { url -> String in
                guard let url = url else {
                    throw GetUrlMissingError()
                }
                return url
            }.eraseToAnyPublisher()
        let closingUrlPublisher: AnyPublisher<String, Error> = self.appConfigRepository.value(
            for: "marketplaceCloseUrl",
               defaultValue: defaultClosingUrl
        )
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        let tokenPublisher = self.repository.fetchSoapTokenCredential()
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        return Publishers.Zip3(urlPublisherWithError, closingUrlPublisher, tokenPublisher)
            .map() { (url, closingUrl, token) -> WebViewConfiguration in
                var latitude = ""
                var longitude = ""
                if let location = location {
                    latitude = String(location.0)
                    longitude = String(location.1)
                }
                let parameters: [String: String] = ["canal": "MOV", "token": token, "latitude": latitude, "longitude": longitude]
                let configuration = MarketplaceWebViewConfiguration(initialURL: url,
                                                                    bodyParameters: parameters,
                                                                    closingURLs: [closingUrl],
                                                                    webToolbarTitleKey: "toolbar_title_marketplace",
                                                                    pdfToolbarTitleKey: nil,
                                                                    pdfSource: .unknown)
                return configuration
            }
            .eraseToAnyPublisher()
    }
}
