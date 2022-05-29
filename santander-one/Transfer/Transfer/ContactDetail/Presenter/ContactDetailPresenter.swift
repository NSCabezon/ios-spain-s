import Foundation
import CoreFoundationLib

protocol ContactDetailPresenterProtocol: AnyObject {
    var view: ContactDetailViewProtocol? { get set }
    func viewDidLoad()
    func didSelectShareAccount(_ viewModel: ContactDetailItemViewModel)
    func didSelectNewTransfer()
    func didSelectDismiss()
    func didSelectEditContact()
    func didSelectDeleteContact()
}

class ContactDetailPresenter {
    weak var view: ContactDetailViewProtocol?
    let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var extendedConfiguration: ContactDetailExtendedConfiguration {
        return self.dependenciesResolver.resolve(for: ContactDetailExtendedConfiguration.self)
    }
    
    private var coordinator: ContactDetailCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: ContactDetailCoordinatorProtocol.self)
    }
    
    private var coordinatorDelegate: ContactDetailCoordinatorDelegate {
        return self.dependenciesResolver.resolve(for: ContactDetailCoordinatorDelegate.self)
    }
    
    private var configuration: ContactDetailConfiguration {
        return self.dependenciesResolver.resolve(for: ContactDetailConfiguration.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
}

extension ContactDetailPresenter: ContactDetailPresenterProtocol {
    func viewDidLoad() {
        trackScreen()
        self.handleContact()
    }
    
    func didSelectShareAccount(_ viewModel: ContactDetailItemViewModel) {
        trackEvent(.share, parameters: [:])
        self.coordinator.didSelectShare(viewModel)
    }
    
    func didSelectNewTransfer() {
        trackEvent(.newSend, parameters: [:])
        let entity = extendedConfiguration.favorite.favorite
        let account = configuration.account
        if let contactDetailModifier = self.contactDetailModifier {
            contactDetailModifier.didSelectTransferForFavorite(entity, accountEntity: account, enabledFavouritesCarrusel: false)
        } else {
            if extendedConfiguration.favorite.isSepa {
                self.coordinatorDelegate.didSelectNewShipment(favorite: entity, accountEntity: account)
            } else {
                guard let noSepaPayeeDetail = extendedConfiguration.favorite.noSepaPayeeDetail else { return }
                self.coordinatorDelegate.didSelectNoSepaNewShipment(entity, accountEntity: account, noSepaPayeeDetailEntity: noSepaPayeeDetail)
            }
        }
    }
    
    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
    
    func didSelectEditContact() {
        trackEvent(.edit, parameters: [:])
        let favoriteType = extendedConfiguration.favorite
            if extendedConfiguration.favorite.isSepa {
                self.coordinatorDelegate.didSelectUpdateFavorite(favoriteType: favoriteType)
            } else {
                guard let noSepaPayeeDetail = extendedConfiguration.favorite.noSepaPayeeDetail else { return }
                self.coordinatorDelegate.didSelectUpdateNoSepaFavorite(favorite: favoriteType.favorite, noSepaPayeeDetailEntity: noSepaPayeeDetail)
            }
    }
    
    func didSelectDeleteContact() {
        trackEvent(.delete, parameters: [:])
        self.coordinatorDelegate.didDeleteFavourite(favoriteType: self.extendedConfiguration.favorite)
    }
}

private extension ContactDetailPresenter {
    var contactDetailModifier: ContactDetailModifierProtocol? {
        return dependenciesResolver.resolve(forOptionalType: ContactDetailModifierProtocol.self)
    }
    
    func handleContact() {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let colorType = colorsEngine.get(self.extendedConfiguration.favorite.alias ?? "")
        let colorByNameViewModel = ColorsByNameViewModel(colorType)
        let contactDetailViewModel = ContactDetailViewModel(
            favoriteType: self.extendedConfiguration.favorite,
            sepaInfoList: self.extendedConfiguration.sepaList,
            baseUrl: self.baseURLProvider.baseURL,
            colorsByNameViewModel: colorByNameViewModel
        )
        self.view?.setContactDetailViewModel(contactDetailViewModel)
    }
}

extension ContactDetailPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: SendMoneyDetailFavoritePage {
        return SendMoneyDetailFavoritePage()
    }
}
