import CoreFoundationLib

class ImageListFullscreenPresenter: PrivatePresenter<ImageListFullscreenViewController, PrivateHomeNavigator & PullOffersActionsNavigatorProtocol, ImageListFullscreenPresenterProtocol> {
    
    var title: LocalizedStylableText? {
        guard let titleKey = imageListAction.topTitle, titleKey != "" else {
            return stringLoader.getString("toolbar_title_commercialOffer")
        }
        return stringLoader.getString(titleKey)
    }
    var selectedPosition: Int = 0
    private var imageListAction: ImageListAction
    var offerId: String?
    
    override var shouldOpenDeepLinkAutomatically: Bool {
        return sessionManager.isSessionActive
    }
    
    init(pullOffersImageListConfiguration: PullOffersImageListConfiguration, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: PrivateHomeNavigator & PullOffersActionsNavigatorProtocol) {
        self.imageListAction = pullOffersImageListConfiguration.imageListAction
        self.offerId = pullOffersImageListConfiguration.offerId
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.show(barButton: .close)
        view.styledTitle = title
        view.imageListFullscreenContainerPageViewController.actionDelegate = self
        setFullscreenDetailViews()
        selectedPage(index: 0)
        if !sessionManager.isSessionActive {
            view.setupPublicNavigationBar()
        }
    }
    
    private func setFullscreenDetailViews() {
        guard imageListAction.list.count > 0 else { return }
        view.setPageControl(count: imageListAction.list.count)
        let imageListFullscreenPageViewControllers = imageListAction.list.map { listPage -> ImageListFullscreenPageViewController in
            let imageFullScreenPresenter = navigator.presenterProvider.imageFullScreenPresenter(with: listPage)
            return imageFullScreenPresenter.view
        }
        view.addPages(pages: imageListFullscreenPageViewControllers, selectedPosition: selectedPosition)
    }
}

extension ImageListFullscreenPresenter: Presenter {}

extension ImageListFullscreenPresenter {
    
    var pullOffersActionsManagers: PullOfferActionsManager {
        return dependencies.pullOfferActionsManager
    }
}

extension ImageListFullscreenPresenter: ImageListFullscreenPresenterProtocol {
    func buttonSelected() {
        let pages = imageListAction.list
        
        let imageFullscreenPage = pages[selectedPosition]
        guard let offerAction = imageFullscreenPage.action else { return }
        executeOffer(action: offerAction, offerId: offerId, location: nil)
    }
    
    func buttonPressed() {
        expireOffer(offerId: offerId)
        navigator.closeAllPullOfferActions()
    }
}

extension ImageListFullscreenPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension ImageListFullscreenPresenter: ImageListFullscreenContainerPageViewDelegate {
    func selectedPage(index: Int) {
        selectedPosition = index
    }
}
