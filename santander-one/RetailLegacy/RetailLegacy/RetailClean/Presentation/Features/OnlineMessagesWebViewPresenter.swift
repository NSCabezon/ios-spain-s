import UIKit
import CoreFoundationLib

final class OnlineMessagesWebViewPresenter: BaseWebViewPresenter {
    override var screenId: String? {
        return TrackerPagePrivate.OnlineMessages().page
    }
    
    override func loadViewData() {
        super.loadViewData()
    }
    
    func showPresenterLoading(type: LoadingViewType) {
        let text = LoadingText(title: localized(key: "generic_popup_loadingContent"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil, loadingImageType: .points)
        showLoading(info: info)
    }
    
    override var title: LocalizedStylableText? {
        return stringLoader.getString("mailbox_title_onlineMail")
    }
}

extension OnlineMessagesWebViewPresenter: OnlineMessagesWebViewPresenterProtocol {}

extension OnlineMessagesWebViewPresenter: TabContainerPresenterType {
    var tabTitle: LocalizedStylableText {
        return stringLoader.getString("mailbox_tab_onlineMessages")
    }
    
    var tabIconKey: String? {
        return "icnNotificationOnlineOff"
    }
}

extension OnlineMessagesWebViewPresenter: ViewControllerProxy {
    var viewController: UIViewController {
        return view
    }
}
