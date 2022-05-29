import CoreFoundationLib
import Foundation

protocol TransferSearchableConfigurationSelectionPresenterDelegate: class {
    func didSelect<Item>(_ item: Item)
    func closeButton()
}

protocol TransferSearchableConfigurationSelectionNavigatorProtocol: class {}

class TransferSearchableConfigurationSelectionPresenter<Item: FilterableSortableAndTitleDescriptionRepresentable>: PrivatePresenter<TransferSearchableConfigurationSelectionViewController, TransferSearchableConfigurationSelectionNavigatorProtocol & PullOffersActionsNavigatorProtocol, TransferSearchableConfigurationSelectionPresenterProtocol> {
    
    // MARK: Public attributes
    var locations: [PullOfferLocation] {
        return PullOffersLocationsFactory().countrySelector
    }
    weak var delegate: TransferSearchableConfigurationSelectionPresenterDelegate?
    
    // MARK: - Private attributes
    private var presenterOffers: [PullOfferLocation: Offer] = [:]    
    private var section: TableModelViewSection?
    /// Represents the whole list of items passed to this section
    private var items: [Item] = []
    private var selected: Item?
    private let account: Account?
    private let configuration = TransferSearchableConfiguration()
    
    /// Class to save the information related to the view state (if items are filtered in view, in the items in view are different to the whole list).
    fileprivate class TransferSearchableConfiguration {
        /// A boolean to know if items shown are filtered
        var areItemsFiltered: Bool = false
        /// Represents the list of items shown in view
        var showedItems: [Item] = []
    }
    
    // MARK: - Public methods
    
    init(dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: TransferSearchableConfigurationSelectionNavigatorProtocol & PullOffersActionsNavigatorProtocol, account: Account?, items: [Item], delegate: TransferSearchableConfigurationSelectionPresenterDelegate? = nil, selected: Item? = nil) {
        self.items = items
        self.delegate = delegate
        self.selected = selected
        self.account = account
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        view.show(barButton: .close)
        let section = TableModelViewSection()
        self.section = section
        showAccountAndSearchHeader()
        showFavs()
        showItems(items)
        switch items.first {
        case is SepaCurrencyInfo:
            view.title = localized(key: "toolbar_title_currency").text
            view.hideBannerView()
        case is SepaCountryInfo:
            getLocationsOption()
            view.title = localized(key: "toolbar_title_country").text
        default: break
        }
        self.view.sections = [section]
    }
    
    override var screenId: String? {
        switch items.first {
        case is SepaCountryInfo: return TrackerPagePrivate.TransferCountrySelector().page
        default: return nil
        }
    }
    
    // MARK: - Private methods
    private func getLocationsOption() {
        getCandidateOffers { [weak self] candidates in
            guard let strongSelf = self else { return }
            strongSelf.presenterOffers = candidates
            if let offer = candidates[.FXPAY], let url = offer.banners.first?.url {
                let model = ImageBannerViewModel(url: url, bannerOffer: offer, isClosable: true, isRounded: false, actionDelegate: strongSelf, dependencies: strongSelf.dependencies)
                model.configureView(in: strongSelf.view.locationView)
            } else {
                strongSelf.view.hideBannerView()
            }
        }
    }
    
    private func showItems(_ items: [Item]) {
        if items.count == 0 {
            let emptyModelView = EmptyViewModelView(dependencies.stringLoader.getString("generic_label_emptyListResult"), dependencies)
            section?.add(item: emptyModelView)
            emptyModelView.accessibilityIdentifier = "generic_label_emptyListResult"
            configuration.showedItems = []
        } else {
            let sortedItems = items.sorted(by: { $0.sortedBy() < $1.sortedBy() })
            section?.addAll(items: sortedItems.map({ LabelViewModel(dependencies: dependencies, item: $0, isSelected: $0 == selected, accessibilityIdentifier: $0.representableTitle) }))
            configuration.showedItems = sortedItems
        }
    }
    
    private func showAccountAndSearchHeader() {
        guard let account = self.account else {
            view.setHiddenHeader(hidden: true)
            return
        }
        view.setHiddenHeader(hidden: false)
        view.setHeader(AccountHeaderViewModel(accountAlias: account.getAliasUpperCase(), accountIBAN: account.getIBANShort(), accountAmount: account.getAmountUI()))
    }
    
    private func hideFavs() {
        section?.remove(index: 0)
    }
    
    private func showFavs() {
        if items.count > 5 {
            let selectedIndex: Int? = {
                if let index = items.firstIndex(where: { $0 == selected }), index < 5 {
                    return index
                }
                return nil
            }()
            let favViewModel = TransferSearchableConfigurationFavsItemViewModel(
                dependencies: dependencies,
                firstItem: items[0],
                secondItem: items[1],
                thirdItem: items[2],
                fourthItem: items[3],
                fifthItem: items[4],
                delegate: self,
                selectedIndex: selectedIndex
            )
            section?.add(item: favViewModel)
        }
    }
    
    private func clear() {
        section?.clean()
        view.clearSections()
        configuration.showedItems = []
    }
}

extension TransferSearchableConfigurationSelectionPresenter: CloseButtonAwarePresenterProtocol {
    func closeButtonTouched() {
        delegate?.closeButton()
    }
}

extension TransferSearchableConfigurationSelectionPresenter: TransferSearchableConfigurationFavsTableViewCellDelegate {
    
    func favsDidSelectIndex(_ index: Int) {
        guard items.indices.contains(index) else { return }
        self.delegate?.didSelect(items[index])
    }
}

extension TransferSearchableConfigurationSelectionPresenter: TransferSearchableConfigurationSelectionPresenterProtocol {
    func userDidSearch(_ term: String) {
        clear()
        if term.isEmpty {
            showFavs()
            configuration.areItemsFiltered = false
            showItems(items)
        } else {
            let filteredItems = items.filter({ $0.isIncludedFilteredBy(term) })
            configuration.areItemsFiltered = true
            showItems(filteredItems)
        }
        guard let section = section else { return }
        self.view.sections = [section]
    }
    
    func didSelectIndex(_ index: Int) {
        // Avoid to tap in favs cell
        if section?.get(index) is LabelViewModel {
            let index = configuration.areItemsFiltered ? index : index - 1
            guard configuration.showedItems.indices.contains(index) else { return }
            self.delegate?.didSelect(configuration.showedItems[index])
        }
    }
}

extension TransferSearchableConfigurationSelectionPresenter: LocationsResolver {}

extension TransferSearchableConfigurationSelectionPresenter: LocationBannerDelegate {
    
    func closeBanner(bannerOffer: Offer?) {
        expireOffer(offerId: bannerOffer?.id)
        removeOffer(location: .FXPAY)
        view.hideBannerView()
    }
    
    func finishDownloadImage(newHeight: Float?) {
        view.onDrawFinished(newHeight: newHeight)
    }
    
    func selectedBanner() {
        if let offer = presenterOffers[.FXPAY] {
            guard let offerAction = offer.action else { return }
            executeOffer(action: offerAction, offerId: offer.id, location: PullOfferLocation.FXPAY)
        }
    }
}

extension TransferSearchableConfigurationSelectionPresenter: PullOfferActionsPresenter {
    var presentationView: ViewControllerProxy {
        return view
    }
    
    var pullOffersActionsNavigator: PullOffersActionsNavigatorProtocol {
        return navigator
    }
}
