class TipsPresenter: PrivatePresenter<TipsViewController, TipNavigatorProtocol, TipsPresenterProtocol> {

    // MARK: - TrackerScreenProtocol

    override var screenId: String? {
        return TrackerPagePrivate.Tips().page
    }

    // MARK: -

    private var tips: [PullOffersConfigTip]?
    private var offers: [Offer]?
    
    override func loadViewData() {
        super.loadViewData()
        view.styledTitle = dependencies.stringLoader.getString("toolbar_title_tips")
        let usecase = dependencies.useCaseProvider.getTipsUseCase()
        UseCaseWrapper(with: usecase, useCaseHandler: dependencies.useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] (response) in
            guard let strongSelf = self else { return }
            let section = TableModelViewSection()
            if let tips = response.tips {
                strongSelf.tips = tips
                strongSelf.offers = response.offers
                for tip in tips {
                    let model = TipModelView(tip: tip, dependencies: strongSelf.dependencies)
                    section.add(item: model)
                }
            }
            strongSelf.view.setSection(section)
        })
    }
}

// MARK: - TipsPresenterProtocol

extension TipsPresenter: TipsPresenterProtocol {
    func selectedItem(index: Int) {
        guard let tips = tips else { return }
        let selectedOfferId = tips[index].offerId
        guard let offer = offers?.first(where: { $0.id == selectedOfferId }) else { return }
        trackEvent(eventId: TrackerPagePrivate.Tips.Action.selectAdvice.rawValue, parameters: [:])
        executeOffer(action: offer.action, offerId: tips[index].offerId, location: nil)
    }
}

// MARK: - Pull offers actions presenter

extension TipsPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}

// MARK: - SideMenuCapable

extension TipsPresenter: SideMenuCapable {
    func toggleSideMenu() {
        navigator.toggleSideMenu()
    }
    
    var isSideMenuAvailable: Bool {
        return true
    }
}
