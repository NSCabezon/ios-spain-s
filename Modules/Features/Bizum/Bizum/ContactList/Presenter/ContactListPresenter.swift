import CoreFoundationLib

protocol ContactListDelegate: class {
    func didContactSelected(viewModel: BizumContactListViewModel)
}

protocol ContactListPresenterProtocol {
    func viewDidLoad()
    func didSelectRow(viewModel: BizumContactListViewModel)
    func textFieldDidSet(text: String)
}

final class ContactListPresenter {
    var view: ContactListViewControllerProtocol?
    private let dependenciesResolver: DependenciesResolver
    weak var delegate: ContactListDelegate?
    private var contactsImageStatusUseCase: GetContactListWithImageStatusUseCase {
        return GetContactListWithImageStatusUseCase(dependenciesResolver: self.dependenciesResolver)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

private extension ContactListPresenter {
    var contactPermission: ContactPermissionsManagerProtocol {
        return dependenciesResolver.resolve(for: ContactPermissionsManagerProtocol.self)
    }
    var bizumConfiguration: BizumCheckPaymentConfiguration {
        return dependenciesResolver.resolve(for: BizumCheckPaymentConfiguration.self)
    }
    
    func getContacts() {
        self.view?.showLoadingView(nil)
        Scenario(useCase: contactsImageStatusUseCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                self?.contactPermission.getContacts(includingImages: result.retrieveImageWithContacts) { [weak self] userContactEntity, _ in
                    guard let self = self else { return }
                    self.getContactsListUseCase(userContactEntity)
                }
            }
    }
    
    func getContactsListUseCase(_ contacts: [UserContactEntity]?) {
        guard let contacts = contacts,
            let bizumContactList = self.getContactPhonesViewModel(userContacts: contacts),
            !bizumContactList.isEmpty
            else {
                self.view?.hideLoadingView(nil)
                return
        }
        let contactList = bizumContactList.map { $0.phone }
        let input = GetContactListUseCaseInput(contactList: contactList)
        let useCase = self.dependenciesResolver.resolve(for: GetContactListUseCase.self).setRequestValues(requestValues: input)
        UseCaseWrapper(
            with: useCase,
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.view?.hideLoadingView(nil)
                self.matchPhonesWithContactList(bizumContactList, bizumContacts: result.bizumContactList.contactList)
            },
            onError: { [weak self] _ in
                guard let self = self else { return }
                // Do nothing when web service not working
                self.view?.hideLoadingView(nil)
                self.matchPhonesWithContactList(bizumContactList, bizumContacts: [])
            }
        )
    }
    
    func matchPhonesWithContactList(_ contacts: [BizumContactList], bizumContacts: [String]) {
        var matchingContacts: [BizumContactList] = []
        contacts.forEach { contact in
            let isBizumContact = bizumContacts.contains(contact.phone.notWhitespaces())
            matchingContacts.append(BizumContactList(name: contact.name, phone: contact.phone, isBizum: isBizumContact, thumbnailData: contact.thumbnailData))
        }
        matchingContacts.sort {
            return ($0.name ?? "").localizedCaseInsensitiveCompare($1.name ?? "") == .orderedAscending
        }
        self.view?.showContacts(self.formatEngineColors(entities: matchingContacts))
    }
    
    func getContactPhonesViewModel(userContacts: [UserContactEntity]?) -> [BizumContactList]? {
        guard let userContacts = userContacts else { return nil }
        let formatter = PhoneFormatter()
        var bizumContactList: [BizumContactList] = []
        userContacts.forEach { user in
            user.phones.forEach { phone in
                if let phoneCorrect = formatter.getNationalPhoneCodeTrimmed(phone: phone.number) {
                    bizumContactList.append(BizumContactList(name: user.fullName,
                                                             phone: phoneCorrect,
                                                             thumbnailData: user.thumbnail ))
                }
            }
        }
        return bizumContactList
    }
    
    func formatEngineColors(entities: [BizumContactList]) -> [BizumContactListViewModel] {
        let models = entities.reduce(NSMutableOrderedSet()) {
            let model = BizumContactListViewModel(initials: $1.identifier.nameInitials,
                                                  name: $1.name,
                                                  phone: $1.phone,
                                                  isBizum: $1.isBizum,
                                                  colorModel: self.getColorByName($1.identifier ?? ""),
                                                  thumbnail: $1.thumbnailData)
            $0.add(model)
            return $0
        }
        return Array(models) as? [BizumContactListViewModel]  ?? []
    }
    
    // MARK: - Search
    func performSearch(text: String) {
        guard let contacts = self.view?.contactListViewModels else { return }
        if text.isEmpty {
            self.view?.showSearchContacts(contacts)
        } else {
            let searched = contacts.filter { contact in
                guard let name = contact.name else { return false }
                return name.uppercased().contains(text.uppercased())
            }
            if searched.isEmpty {
                self.view?.setState(.empty)
            }
            self.view?.showSearchContacts(searched)
        }
    }
    
    func getColorByName(_ identifier: String) -> ColorsByNameViewModel {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let colorType = colorsEngine.get(identifier)
        return ColorsByNameViewModel(colorType)
    }
}

extension ContactListPresenter: ContactListPresenterProtocol {
    func viewDidLoad() {
        self.getContacts()
        self.trackScreen()
    }
    
    func didSelectRow(viewModel: BizumContactListViewModel) {
        self.delegate?.didContactSelected(viewModel: viewModel)
        self.trackEvent(.contact, parameters: [:])
    }
    
    func textFieldDidSet(text: String) {
        self.view?.setState(.searching)
        self.performSearch(text: text)
        self.trackEvent(.search, parameters: [.textSearch: text])
    }
}

extension ContactListPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumContactListPage {
        return BizumContactListPage()
    }
}
