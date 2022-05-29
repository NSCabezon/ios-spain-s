import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class SetupPushNotificationsInboxUseCase: UseCase<Void, SetupPushNotificationsInboxUseCaseOkOutput, StringErrorOutput> {
    private let appConfigRepository: AppConfigRepository
    private let bsanManagersProvider: BSANManagersProvider
    
    init(appConfigRepository: AppConfigRepository, bsanManagersProvider: BSANManagersProvider) {
        self.appConfigRepository = appConfigRepository
        self.bsanManagersProvider = bsanManagersProvider
    }
    
    override public func executeUseCase(requestValues: Void) throws -> UseCaseResponse<SetupPushNotificationsInboxUseCaseOkOutput, StringErrorOutput> {
        let isEnabled = appConfigRepository.getAppConfigBooleanNode(nodeName: DomainConstant.appConfigEnableOnlineMessagesInbox) ?? false
        guard isEnabled, let url: String = appConfigRepository.getAppConfigNode(nodeName: DomainConstant.appConfigonlineMessagesInboxUrl) else {
            return UseCaseResponse.ok(SetupPushNotificationsInboxUseCaseOkOutput(enableOnlineMessagesInbox: isEnabled, urlOnlineMessagesInbox: nil))
        }
        
        let token = try bsanManagersProvider.getBsanAuthManager().getAuthCredentials().soapTokenCredential
        let parameters = [
            "token": token
        ]
        
        let webViewConfiguration = OnlineMessagesWebViewConfiguration(initialURL: url, bodyParameters: parameters, pdfToolbarTitleKey: "toolbar_title_pdfMessages", pdfSource: .unknown)
        
        return UseCaseResponse.ok(SetupPushNotificationsInboxUseCaseOkOutput(enableOnlineMessagesInbox: isEnabled, urlOnlineMessagesInbox: webViewConfiguration))
    }
}

struct SetupPushNotificationsInboxUseCaseOkOutput {
    let enableOnlineMessagesInbox: Bool?
    let urlOnlineMessagesInbox: WebViewConfiguration?
}
