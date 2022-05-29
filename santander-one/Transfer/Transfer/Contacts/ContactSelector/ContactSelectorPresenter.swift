import TransferOperatives
import CoreFoundationLib
import CoreDomain
import Foundation
import UI

protocol ContactSelectorPresenterProtocol: AnyObject {
    var view: ContactSelectorViewProtocol? { get set }
    func viewDidLoad()
    func didSelectContact(_ viewModel: ContactViewModel)
    func didSelectNewContact()
    func didSelectClose()
    func didSelectDismiss()
    func didSelectMenu()
    func didTapOnShareViewModel(_ viewModel: ContactViewModel)
    func didSelectSaveSortedContacts(_ contacts: [ContactListItemViewModel])
}

class ContactSelectorPresenter {
    weak var view: ContactSelectorViewProtocol?
    let dependenciesResolver: DependenciesResolver
    private var isEnabledCreate: Bool?
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private weak var delegate: ContactSelectorDelegate? {
        return dependenciesResolver.resolve(for: ContactSelectorDelegate.self)
    }
}

extension ContactSelectorPresenter: ContactSelectorPresenterProtocol {
    
    func didTapOnShareViewModel(_ viewModel: ContactViewModel) {
        trackEvent(.share, parameters: [:])
        self.coordinator.share(for: viewModel)
    }

    func didSelectDismiss() {
        self.coordinator.dismiss()
    }
    
    func didSelectClose() {
        self.coordinator.dismiss()
    }
    
    func didSelectMenu() {
        self.coordinator.goToPrivateMenu()
    }
    
    func didSelectNewContact() {
        self.trackEvent(.newContact, parameters: [:])
        if self.isEnabledCreate == true {
            self.coordinator.goToNewContact()
        } else {
            self.view?.showNotAvaliableToast()
        }
    }
    
    func didSelectSaveSortedContacts(_ contacts: [ContactListItemViewModel]) {
        let favoriteContacts = contacts.compactMap { $0.contact.payeeAlias }
        let input = SetFavoriteContactsUseCaseInput(favoriteContacts: favoriteContacts)
        saveSorted(requestValues: input)
    }
    
    func didSelectContact(_ viewModel: ContactViewModel) {
        guard let view = self.view else { return }
        trackEvent(.showFavorite, parameters: [:])
        self.coordinator.goToContactDetail(contact: viewModel.contact, launcher: self, delegate: view)
    }
    
    func viewDidLoad() {
        self.trackScreen()
        self.view?.showLoading()
        MainThreadUseCaseWrapper(
            with: self.getConfigurationUseCase,
            onSuccess: { [weak self] configurationResult in
                if !configurationResult.isEnabledEdit {
                    self?.view?.disableEditMode()
                }
                self?.view?.setupNavigationBar(showCloseButton: configurationResult.showCloseButton)
                self?.isEnabledCreate = configurationResult.isEnabledCreate
                self?.contactsEngine.fetchContacts { [weak self] result in
                    switch result {
                    case .success(let contacts):
                        self?.handleContacts(contacts, sepaList: configurationResult.sepaList)
                    case .failure:
                        self?.view?.dismissLoading()
                        self?.view?.showError()
                    }
                }
            }
        )
    }
}

extension ContactSelectorPresenter: ModuleLauncher {}

private extension ContactSelectorPresenter {
    
    private var coordinator: ContactSelectorCoordinatorProtocol {
        self.dependenciesResolver.resolve(for: ContactSelectorCoordinatorProtocol.self)
    }
    
    private var contactsEngine: ContactsEngineProtocol {
        self.dependenciesResolver.resolve(for: ContactsEngineProtocol.self)
    }
    
    private var baseURLProvider: BaseURLProvider {
        self.dependenciesResolver.resolve(for: BaseURLProvider.self)
    }
    
    private var getConfigurationUseCase: GetContactSelectorConfigurationUseCaseProtocol {
        self.dependenciesResolver.resolve(firstTypeOf: GetContactSelectorConfigurationUseCaseProtocol.self)
    }
    
    private var setFavoriteContactsUseCase: SetFavoriteContactsUseCase {
        return dependenciesResolver.resolve(for: SetFavoriteContactsUseCase.self)
    }
    
    func handleContacts(_ contacts: [PayeeRepresentable], sepaList: SepaInfoListEntity) {
        guard !contacts.isEmpty else {
            self.view?.dismissLoading()
            self.view?.showError()
            return
        }
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let contactViewModels: [ContactListItemViewModel] = contacts.map { contact in
            let colorType = colorsEngine.get(contact.payeeDisplayName ?? "")
            let colorsByNameViewModel = ColorsByNameViewModel(colorType)
            return ContactListItemViewModel(contact: contact, baseUrl: self.baseURLProvider.baseURL, sepaInfoList: sepaList, colorsByNameViewModel: colorsByNameViewModel, showCurrencySymbol: true)
        }
        self.view?.dismissLoading()
        self.view?.showContacts(contactViewModels)
    }
    
    func saveSorted(requestValues: SetFavoriteContactsUseCaseInput) {
        UseCaseWrapper(
            with: self.setFavoriteContactsUseCase.setRequestValues(requestValues: requestValues),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] _ in
                self?.trackEvent(.order, parameters: [:])
                self?.delegate?.didSortedContacts()
            }
        )
    }
}

extension ContactSelectorPresenter: AutomaticScreenActionTrackable {
    
    var trackerPage: ContactSelectorPage {
        ContactSelectorPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
