import Foundation
import CoreFoundationLib

class OnePayTransferFavouritesPresenter: PrivatePresenter<OnePayTransferFavouritesViewController, OnePayTransferNavigatorProtocol, OnePayTransferFavouritesPresenterProtocol> {
    private weak var delegate: OnePayTransferDestinationDelegate?
    private let favourites: [FavoriteType]
    private let country: SepaCountryInfo
    private let currency: SepaCurrencyInfo

     init(delegate: OnePayTransferDestinationDelegate, country: SepaCountryInfo, currency: SepaCurrencyInfo, favourites: [FavoriteType], dependencies: PresentationComponent, sessionManager: CoreSessionManager, navigator: OnePayTransferNavigatorProtocol) {
        self.delegate = delegate
        self.favourites = favourites
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
                
        let section = TableModelViewSection()
        if favourites.isEmpty {
            view.sections = makeEmptyViewSection()
            return
        }
        
        let items = favourites.map {
            FavoriteTransferRecipientViewModel(title: LocalizedStylableText(text: $0.alias ?? "", styles: nil), subtitle: LocalizedStylableText(text: $0.account ?? "", styles: nil), country: LocalizedStylableText(text: country.name, styles: nil), currency: LocalizedStylableText(text: currency.name, styles: nil), dependencies: dependencies)
        }
        section.addAll(items: items)
        view.sections = [section]
    }
    
    private func makeEmptyViewSection() -> [TableModelViewSection] {
        let emptyViewSection = EmptyViewSection()
        
        emptyViewSection.add(item: EmptyViewModelView(stringLoader.getString("emptyFavoritesRecipients_label_notFavorite", [StringPlaceholder(.value, country.name)]), dependencies))
        return [emptyViewSection]
    }
}

extension OnePayTransferFavouritesPresenter: OnePayTransferFavouritesPresenterProtocol {
    func selectedIndex(index: Int) {
        guard favourites.count > index else {
            return
        }
        delegate?.selectedFavourite(item: favourites[index])
        navigator.close()
    }
    
    func onCloseButtonTouched() {
        navigator.close()
    }
}
