import CoreFoundationLib
import CoreDomain

class CreativityOfferPresenter: PrivatePresenter<CreativityOfferViewController, PrivateHomeNavigator & PullOffersActionsNavigatorProtocol, CreativityOfferPresenterProtocol> {
    
    private let creativityAction: CreativityAction
    var items: [CreativityCarouselCollectionViewModel] = []
    var offerId: String?
    
    override var shouldOpenDeepLinkAutomatically: Bool {
        return sessionManager.isSessionActive
    }
    
    init(configuration: PullOffersCreativityConfiguration, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: PrivateHomeNavigator & PullOffersActionsNavigatorProtocol) {
        self.creativityAction = configuration.creativityAction
        self.offerId = configuration.offerId
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.title = !creativityAction.topTitle.isEmpty ? creativityAction.topTitle : dependencies.stringLoader.getString("toolbar_title_commercialOffer").text
        
        configureButtons()
        
        updateBanners()
        
        view.setCarouselTotalElements(number: items.count)
        view.show(barButton: .close)
        view.reloadData()
        if !sessionManager.isSessionActive {
            view.setupPublicNavigationBar()
        }
    }
    
    private func configureButtons() {
        configureTopButton()
        configureBottomButtons()
    }
    
    private func configureTopButton() {
        guard let buttonUp = creativityAction.buttonUp, let url = buttonUp.background?.first?.url else {
            view.updateTopButtonConstraint(0)
            return
        }
        
        dependencies.imageLoader.loadWithAspectRatio(absoluteUrl: url, button: view.imageViewButton) { [weak self] newHeight in
            self?.view.updateTopButtonConstraint(newHeight)
        }
        view.configure(topButton: buttonUp)
    }
    
    private func configureBottomButtons() {
        var buttons: [OfferButton] = []
        if let rightButton = creativityAction.buttonRight {
            buttons.append(rightButton)
        }
        
        if let leftButton = creativityAction.buttonLeft {
            buttons.append(leftButton)
        }
        
        view.configure(bottomButtons: buttons)
    }
    
    private func updateBanners() {
        var list: [CreativityCarouselCollectionViewModel] = []
        
        for banner in creativityAction.carousel where banner.app.lowercased().contains("ios") {
            list.append(CreativityCarouselCollectionViewModel(url: banner.url, width: banner.width, dependencies: dependencies))
        }
        self.items = list
    }
}

extension CreativityOfferPresenter: CreativityOfferPresenterProtocol {
    func closeButtonPressed() {
        expireOffer(offerId: offerId)
        navigator.closeAllPullOfferActions()
    }
    
    func execute(offerAction: OfferActionRepresentable?) {
        self.executeOffer(action: offerAction, offerId: offerId, location: nil)
    }
}

extension CreativityOfferPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension CreativityOfferPresenter {
    
    var pullOffersActionsManagers: PullOfferActionsManager {
        return dependencies.pullOfferActionsManager
    }
}

extension CreativityOfferPresenter: Presenter {}
