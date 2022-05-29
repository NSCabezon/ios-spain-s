import Foundation
import CoreFoundationLib
import CoreDomain

class PullOfferDetailPresenter: PrivatePresenter<PullOfferDetailViewController, PrivateHomeNavigator & PullOffersActionsNavigatorProtocol, PullOfferDetailPresenterProtocol> {
    private var detailConfiguration: PullOffersDetailConfiguration
    
    var title: LocalizedStylableText? {
        guard let titleKey = detailConfiguration.topTitle, titleKey != "" else {
            return stringLoader.getString("toolbar_title_commercialOffer")
        }
        return stringLoader.getString(titleKey)
    }
    
    override var shouldOpenDeepLinkAutomatically: Bool {
        return sessionManager.isSessionActive
    }
    
    init(detailConfiguration: PullOffersDetailConfiguration, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: PrivateHomeNavigator & PullOffersActionsNavigatorProtocol) {
        self.detailConfiguration = detailConfiguration
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.show(barButton: .close)
        view.styledTitle = title
        
        let sectionContent = TableModelViewSection()
        
        if let banner = detailConfiguration.banner {
            let imageModel = TutorialImageTableViewModel(url: banner.url, actionDelegate: self, dependencies: dependencies)
            sectionContent.items.append(imageModel)
        }
        if let description = detailConfiguration.description {
            let titleLabelModel = OperativeLabelTableModelView(title: LocalizedStylableText(text: description, styles: nil), style: nil, insets: Insets(left: 28, right: 16, top: 18, bottom: 15), isHtml: true, privateComponent: dependencies)
            sectionContent.items.append(titleLabelModel)
        }
        view.configureOfferButtons(offerButton1: detailConfiguration.button1, offerButton2: detailConfiguration.button2)
        view.sections = [sectionContent]
    }
}

extension PullOfferDetailPresenter: Presenter {}

extension PullOfferDetailPresenter: PullOfferDetailPresenterProtocol {
    func buttonSelected(action: OfferActionRepresentable?) {
        self.executeOffer(action: action, offerId: detailConfiguration.offerId, location: nil)
    }
    
    func buttonPressed() {
        expireOffer(offerId: detailConfiguration.offerId)
        navigator.closeAllPullOfferActions()
    }
}

extension PullOfferDetailPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension PullOfferDetailPresenter: TutorialImageTableViewModelDelegate {
    func finishDownloadImage() {
        view.calculateHeight()
    }
}
