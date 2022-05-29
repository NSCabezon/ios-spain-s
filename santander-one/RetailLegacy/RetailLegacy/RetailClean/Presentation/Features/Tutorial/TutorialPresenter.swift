import Foundation
import CoreFoundationLib

struct TutorialPullOfferNotifications {
    static let closePullOffer = Notification.Name(rawValue: "TutorialPullOfferNotifications.closePullOffer")
}

class TutorialPresenter: PrivatePresenter<TutorialViewController, PrivateHomeNavigator & PullOffersActionsNavigatorProtocol, TutorialPresenterProtocol> {
    
    private var tutorialConfiguration: PullOffersTutorialConfiguration
    
    var title: LocalizedStylableText? {
        guard let titleKey = tutorialConfiguration.topTitle, titleKey != "" else {
            return stringLoader.getString("toolbar_title_commercialOffer")
        }
        return stringLoader.getString(titleKey)
    }
    
    var selectedPosition: Int! = 0
    var offerId: String?
    
    override var shouldOpenDeepLinkAutomatically: Bool {
        return sessionManager.isSessionActive
    }
    
    init(tutorialConfiguration: PullOffersTutorialConfiguration, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: PrivateHomeNavigator & PullOffersActionsNavigatorProtocol) {
        self.tutorialConfiguration = tutorialConfiguration
        self.offerId = tutorialConfiguration.offerId
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.show(barButton: .close)
        view.styledTitle = title
        view.tutorialContainerPageViewController.actionDelegate = self
        setTutorialDetailViews()
        selectedPage(index: 0)
    }
    
    private func setTutorialDetailViews() {
        guard tutorialConfiguration.tutorialPages.count > 0 else { return }
        view.setPageControl(count: tutorialConfiguration.tutorialPages.count)
        let tutorialDetailViewControllers = tutorialConfiguration.tutorialPages.map { tutorialPage -> TutorialDetailViewController in
            let tutorialDetailPresenter = navigator.presenterProvider.tutorialDetailPresenter(with: tutorialPage)
            return tutorialDetailPresenter.view
        }
        view.addPages(pages: tutorialDetailViewControllers, selectedPosition: selectedPosition)
    }
}

extension TutorialPresenter: Presenter {}

extension TutorialPresenter {
    
    var pullOffersActionsManagers: PullOfferActionsManager {
        return dependencies.pullOfferActionsManager
    }
}

extension TutorialPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension TutorialPresenter: TutorialPresenterProtocol {
    func buttonPressed() {
        NotificationCenter.default.post(name: TutorialPullOfferNotifications.closePullOffer, object: self)
        expireOffer(offerId: offerId)
        navigator.closeAllPullOfferActions()
    }
}

extension TutorialPresenter: TutorialContainerPageViewDelegate {
    func selectedPage(index: Int) {
        let pages = tutorialConfiguration.tutorialPages
        
        if index == pages.count-1 {
            view.titleButton = stringLoader.getString("generic_button_understand")
            view.bottomButton.onTouchAction = { [weak self] _ in
                self?.buttonPressed()
            }
        } else {
            let tutorialPage = pages[index]
            view.titleButton = LocalizedStylableText(text: tutorialPage.actionButton?.text ?? "", styles: nil)
            
            view.bottomButton.onTouchAction = { [weak self] _ in
                guard let offerAction = tutorialPage.actionButton?.action else { return }
                self?.executeOffer(action: offerAction, offerId: self?.offerId, location: nil)
            }
        }
    }
}
