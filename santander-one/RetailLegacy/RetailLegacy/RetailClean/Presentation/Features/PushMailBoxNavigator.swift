import CoreFoundationLib

protocol PushMailBoxNavigatorProtocol: TabContainerNavigatorProtocol {
    func getPresenter(option: InboxTabList) -> TabContainerPresenterType
}

class PushMailBoxNavigator: TabContainerNavigator {}

extension PushMailBoxNavigator: PushMailBoxNavigatorProtocol {
    func getPresenter(option: InboxTabList) -> TabContainerPresenterType {
        switch option {
        case .onlineMessages(let config, let linkHandler):
            return presenterProvider.onlineMessagesWKWebViewPresenter(webViewConfiguration: config, linkHandler: linkHandler)
        }
    }
}
