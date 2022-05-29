//
//  GetOnlineMessagesConfigurationUseCase.swift
//  Inbox
//
//  Created by Juan Carlos López Robles on 1/21/20.
//

import Foundation
import CoreFoundationLib
import SANLegacyLibrary

final class GetOnlineMessagesWebViewConfigurationUseCase: UseCase<Void, OnlineMessagesWebViewConfigurationOutput, StringErrorOutput> {
    
    private let appConfigRepository: AppConfigRepositoryProtocol
    private var provider: BSANAuthManager
    
    init(dependenciesResolver: DependenciesResolver) {
        self.appConfigRepository = dependenciesResolver.resolve(for: AppConfigRepositoryProtocol.self)
        let bsanProvider = dependenciesResolver.resolve(for: BSANManagersProvider.self)
        self.provider = bsanProvider.getBsanAuthManager()
    }
    
    override func executeUseCase(requestValues: Void) throws -> UseCaseResponse<OnlineMessagesWebViewConfigurationOutput, StringErrorOutput> {
        let isEnable = appConfigRepository.getBool(InboxConstant.enableOnlineMessagesInbox) ?? false
        let urlString = appConfigRepository.getString(InboxConstant.onlineMessagesInboxUrl)
        guard isEnable, let url = urlString else {
            return .ok(OnlineMessagesWebViewConfigurationOutput(isEnable: isEnable, configuration: nil))
        }
        let token = try provider.getAuthCredentials().soapTokenCredential
        let params = [InboxConstant.token: token]
        let webViewConfiguration = OnlineMessagesWebViewConfiguration(initialURL: url,
                                                                      bodyParameters: params,
                                                                      pdfToolbarTitleKey: InboxConstant.pdfMessage,
                                                                      pdfSource: .unknown)
        return .ok(OnlineMessagesWebViewConfigurationOutput(isEnable: isEnable, configuration: webViewConfiguration))
    }
}

struct OnlineMessagesWebViewConfigurationOutput {
    var isEnable: Bool
    var configuration: WebViewConfiguration?
}
