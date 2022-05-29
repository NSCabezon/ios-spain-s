import UIKit
import UI

protocol PullOffersActionsNavigatorProtocol: BaseWebViewNavigatable, OfferViewNavigatable, AppStoreNavigatable, ShowingDialogOnCenterViewCapable {
    func openYoutubeViewer(videoId: String)
}

extension PullOffersActionsNavigatorProtocol {
    func openYoutubeViewer(videoId: String) {
        MiniPlayerView.play(videoId)
    }

    func openInSafari(url: String) -> ActionPresentationError? {
        guard let validUrl = URL(string: url) else {
            return .badUrl
        }
        return openUrlWithApplication(url: validUrl)
    }
    
    func call(phone: String) -> ActionPresentationError? {
        guard let validPhone = URL(string: "tel://" + phone.notWhitespaces()) else {
            return .badPhone
        }
        return openUrlWithApplication(url: validPhone)
    }
    
    private func openUrlWithApplication(url: URL) -> ActionPresentationError? {
        guard canOpen(url) else {
            return .applicationCanNotOpenUrl
        }
        open(url)
        return nil
    }
}
