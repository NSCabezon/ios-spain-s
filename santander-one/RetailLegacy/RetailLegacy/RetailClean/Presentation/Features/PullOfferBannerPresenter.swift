import UIKit
import CoreFoundationLib

protocol PullOfferBannerNavigatorProtocol: MenuNavigator {
}

class PullOfferBannerPresenter: PrivatePresenter<PullOfferBannerViewController, PullOfferBannerNavigatorProtocol & PullOffersActionsNavigatorProtocol, PullOfferBannerPresenterProtocol> {
    let offers: [Offer]
    let categoryId: String
    
    init(dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: PullOfferBannerNavigatorProtocol & PullOffersActionsNavigatorProtocol, offers: [Offer], categoryId: String) {
        self.offers = offers
        self.categoryId = categoryId
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        if sessionManager.isSessionActive {
            view.styledTitle = dependencies.stringLoader.getString("toolbar_title_personalProducts")
        } else {
            view.styledTitle = dependencies.stringLoader.getString("toolbar_title_publicProducts")
        }
        let sectionContent = TableModelViewSection()
        for offer in offers {
            let banners = !offer.bannersContracts.isEmpty ? offer.bannersContracts: offer.banners
            banners.compactMap {
                BannerViewModel(url: $0.url ?? "", bannerOffer: offer, actionDelegate: self, dependencies: dependencies)
            }.forEach {
                sectionContent.items.append($0)
            }
        }
        view.sections = [sectionContent]
    }
}

extension PullOfferBannerPresenter: BannerViewModelDelegate {
    func finishDownloadImage() {
        view.calculateHeight()
    }
}

extension PullOfferBannerPresenter: PullOfferBannerPresenterProtocol {
    func actionSelectedCell(index: Int) {
        guard let bannerModelView = view.sections[0].items[index] as? BannerViewModel else {
            return
        }
        guard let offer = bannerModelView.bannerOffer else { return }
        track(event: TrackerPagePrivate.ContractOffersForYou.Action.selectOffer.rawValue, screen: TrackerPagePrivate.ContractOffersForYou().page, parameters: [TrackerDimensions.offerId: offer.id ?? "", TrackerDimensions.categoryId: categoryId])
        executeOffer(action: offer.action, offerId: offer.id, location: nil)
    }
}

extension PullOfferBannerPresenter: Presenter {}

extension PullOfferBannerPresenter: SideMenuCapable {
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}

extension PullOfferBannerPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

extension PullOfferBannerPresenter {
    var pullOffersActionsManagers: PullOfferActionsManager {
        return dependencies.pullOfferActionsManager
    }
}
