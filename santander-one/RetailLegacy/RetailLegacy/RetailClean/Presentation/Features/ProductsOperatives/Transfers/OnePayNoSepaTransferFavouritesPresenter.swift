import Foundation
import CoreFoundationLib

class OnePayNoSepaTransferFavouritesPresenter: PrivatePresenter<OnePayTransferFavouritesViewController, OnePayTransferNavigatorProtocol, OnePayTransferFavouritesPresenterProtocol> {
    private lazy var loadUsualTransfersSuperUseCase: LoadUsualTransfersSuperUseCase = {
        return useCaseProvider.getLoadUsualTransfersSuperUseCase(useCaseHandler: useCaseHandler)
    }()
    private weak var delegate: OnePayTransferDestinationDelegate?
    private let country: SepaCountryInfo
    private let currency: SepaCurrencyInfo
    private var favourites: [FavoriteType]?

     init(delegate: OnePayTransferDestinationDelegate, country: SepaCountryInfo, currency: SepaCurrencyInfo, dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: OnePayTransferNavigatorProtocol) {
        self.delegate = delegate
        self.country = country
        self.currency = currency
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
        infoObtained()
    }
    
    private func infoObtained() {
        view.setTitle(title: dependencies.stringLoader.getString("sendMoney_popup_title_favorites"))
        
        let type = LoadingViewType.onView(view: view.tableView, frame: nil, position: .center, controller: view)
        let text = LoadingText(title: localized(key: "generic_popup_loadingContent"), subtitle: localized(key: "loading_label_moment"))
        let info = LoadingInfo(type: type, loadingText: text, placeholders: nil, topInset: nil, loadingImageType: .points)
        showLoading(info: info)
        
        loadUsualTransfersSuperUseCase.execute { [weak self] (transfers) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.hideLoading()
                let favouriteListFiltered: [FavoriteType] = transfers.filter { $0.countryCode == strongSelf.country.code && $0.favorite.amount?.currency?.currencyName == strongSelf.currency.code }
                strongSelf.favourites = favouriteListFiltered

                let section: TableModelViewSection = strongSelf.makeFavouriteViewSection(favourites: favouriteListFiltered)
                strongSelf.view.sections = [section]
            }
        }
    }
    
    private func makeFavouriteViewSection(favourites: [FavoriteType]) -> TableModelViewSection {
        let section = TableModelViewSection()
        if favourites.isEmpty {
            return makeEmptyViewSection()
        }
        let items = favourites.map {
            FavoriteTransferRecipientViewModel(title: LocalizedStylableText(text: $0.alias ?? "", styles: nil), subtitle: LocalizedStylableText(text: $0.favorite.accountDescription ?? "", styles: nil), country: LocalizedStylableText(text: country.name, styles: nil), currency: LocalizedStylableText(text: currency.name.camelCasedString, styles: nil), dependencies: dependencies)
        }
        section.addAll(items: items)
        
        return section
    }
    
    private func makeEmptyViewSection() -> TableModelViewSection {
        let emptyViewSection = EmptyViewSection()
        
        emptyViewSection.add(item: EmptyViewModelView(stringLoader.getString("emptyFavoritesRecipients_label_notFavorite", [StringPlaceholder(.value, country.name)]), dependencies))
        return emptyViewSection
    }
}

extension OnePayNoSepaTransferFavouritesPresenter: OnePayTransferFavouritesPresenterProtocol {
    func selectedIndex(index: Int) {
        guard let favouritesList = favourites, favouritesList.count > index else {
            return
        }
        delegate?.selectedFavourite(item: favouritesList[index])
        navigator.close()
    }
    
    func onCloseButtonTouched() {
        loadUsualTransfersSuperUseCase.cancel()
        DispatchQueue.main.async {
            self.hideLoading()
        }
        navigator.close()
    }
}
