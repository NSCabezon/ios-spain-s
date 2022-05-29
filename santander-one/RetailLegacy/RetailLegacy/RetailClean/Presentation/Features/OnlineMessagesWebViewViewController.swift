import UIKit

protocol OnlineMessagesWebViewPresenterProtocol: Presenter {
}

class OnlineMessagesWebViewViewController: BaseViewController<OnlineMessagesWebViewPresenterProtocol> {
    
    override class var storyboardName: String {
        return "Mailbox"
    }
    
    override func prepareView() {
        super.prepareView()
    }
}
