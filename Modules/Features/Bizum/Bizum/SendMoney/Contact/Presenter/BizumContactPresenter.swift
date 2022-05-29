import Foundation
import CoreFoundationLib
import Operative

protocol BizumContactPresenterProtocol: OperativeStepPresenterProtocol, ValidatableFormPresenterProtocol {
    var view: BizumContactViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func didSelectAcceptWithPhone(_ phone: String)
    func didTapClose()
    func addNewContact()
    func removeContact(identifier: String?)
    func trackRemoveContact()
    func continueAction(contacts: [BizumContactViewModel])
    func didSelectContacts()
    func didSelectFrequentContacts(_ viewModel: BizumFrequentViewModel?)
    func didAllowPermission()
    func getHintContactValue() -> String
}

final class BizumContactPresenter {
    weak var view: BizumContactViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    private let phoneFormatter = PhoneFormatter()
    private let maxNumberContacts: Int = 30
    var container: OperativeContainerProtocol?
    lazy var operativeData: BizumMoneyOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    var fields: [ValidatableField] = []
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumContactPresenter: BizumContactPresenterProtocol {
    var isValidForm: Bool {
        guard let view = self.view, let phone = view.phoneString
        else { return false }
        let phoneFormatter = PhoneFormatter()
        let phoneFormatted = phoneFormatter.checkNationalPhone(phone: phone) == PhoneTextFiledResult.ok
        return phoneFormatted && self.comparePhone(phone: phone)
    }
    
    func viewDidLoad() {
        self.handleContact()
        self.showAccountHeader()
    }
    
    func viewWillAppear() {
        self.trackScreen()
        self.reloadContacts()
        self.updateContinueButton()
    }
    
    func reloadContacts() {
        self.view?.removeAllContacts()
        if let bizumContactEntity = self.operativeData.bizumContactEntity, !bizumContactEntity.isEmpty {
            self.addContacts()
        } else {
            self.view?.addInputArea()
        }
    }
    
    func showAccountHeader() {
        guard let account = self.operativeData.accountEntity else { return }
        let viewModel: SelectAccountHeaderViewModel
        switch self.operativeData.bizumOperativeType {
        case .sendMoney where self.operativeData.accounts.count > 1:
            viewModel = SelectAccountHeaderViewModel(account: account, title: localized("bizum_label_bizumAccount").text, accessibilityIdTitle: AccessibilityBizumContact.bizumHeaderContact, action: self.changeAccountSelected)
            self.view?.set(accountViewModel: viewModel)
        default:
            viewModel = SelectAccountHeaderViewModel(account: account, title: localized("bizum_label_bizumAccount").text, accessibilityIdTitle: AccessibilityBizumContact.bizumHeaderContact, action: nil)
        }
        self.view?.set(accountViewModel: viewModel)
    }
    func addNewContact() {
        guard let view = self.view else { return }
        view.addInputArea()
        self.updateContinueButton()
        self.trackEvent(.addNew, parameters: [:])
    }
    
    func removeContact(identifier: String?) {
        self.removeContactEntity(identifier)
        self.updateContinueButton()
        self.checkIfNeedAddMoreContacts()
        self.trackEvent(.confirmRemoveContact, parameters: [:])
    }
    
    func trackRemoveContact() {
        self.trackEvent(.removeContact, parameters: [:])
    }
    
    func continueAction(contacts: [BizumContactViewModel]) {
        self.container?.rebuildSteps()
        self.container?.save(self.operativeData)
        self.container?.stepFinished(presenter: self)
    }
    
    // MARK: - Validations
    
    func validatableFieldChanged() { }
    
    func didSelectAcceptWithPhone(_ phone: String) {
        guard isValidForm else { self.view?.updateAcceptAction(false); return }
        guard comparePhone(phone: phone) else { return }
        let identifier = phoneFormatter.getNationalPhoneCodeTrimmed(phone: phone) ?? ""
        let viewModel = BizumContactViewModel(identifier: identifier, initials: nil, name: nil, phone: phone, colorModel: self.getColorByName(identifier),
                                              tag: (self.operativeData.bizumContactEntity?.count ?? 0) + 1,
                                              thumbnailData: nil)
        self.addContactAndUpdateView(viewModel)
        self.trackEvent(.phoneNumber, parameters: [:])
    }
    
    func didTapClose() {
        self.container?.close()
    }
    
    func didSelectFrequentContacts(_ viewModel: BizumFrequentViewModel?) {
        guard let viewModel = viewModel, self.view != nil else { return }
        if self.comparePhone(phone: viewModel.phone) {
            let identifier = viewModel.name ?? viewModel.identifier ?? ""
            let contact = BizumContactViewModel(identifier: identifier,
                                                initials: viewModel.avatarName,
                                                name: viewModel.name,
                                                phone: viewModel.phone,
                                                colorModel: getColorByName(identifier),
                                                tag: (self.operativeData.bizumContactEntity?.count ?? 0) + 1, thumbnailData: nil)
            self.addContactAndUpdateView(contact)
        } else {
            self.view?.duplicatePhone()
            self.checkIfNeedAddMoreContacts()
        }
    }
    
    // MARK: Contact list
    func didSelectContacts() {
        let presenter = ContactListPresenter(dependenciesResolver: self.dependenciesResolver)
        presenter.delegate = self
        if self.contactPermission.isContactsAccessEnabled() {
            self.view?.showContacts(with: presenter)
        } else {
            self.view?.showAlertContactList()
        }
        self.trackEvent(.contacts, parameters: [:])
    }
    
    func didAllowPermission() {
        let presenter = ContactListPresenter(dependenciesResolver: self.dependenciesResolver)
        presenter.delegate = self
        self.contactPermission.isAlreadySet { [weak self] isAlreadySet in
            guard let self = self else { return }
            if isAlreadySet {
                self.view?.showDialogPermission()
            } else {
                self.contactPermission.askAuthorizationIfNeeded { authorized in
                    if authorized {
                        self.view?.showContacts(with: presenter)
                    }
                }
            }
        }
    }
    
    func addContactAndUpdateView(_ contact: BizumContactViewModel) {
        self.view?.addContact(viewModel: contact)
        self.addContactEntity(contact)
        self.updateContinueButton()
        self.checkIfNeedAddMoreContacts()
    }
    
    func addContactEntity(_ contact: BizumContactViewModel) {
        let formatter = PhoneFormatter()
        let contactEntity = BizumContactEntity(
            identifier: contact.identifier ?? "",
            name: contact.name,
            phone: formatter.getNationalPhoneCodeTrimmed(phone: contact.phone) ?? "",
            thumbnailData: contact.thumbnailData
        )
        if self.operativeData.bizumContactEntity != nil {
            self.operativeData.bizumContactEntity?.append(contactEntity)
        } else {
            self.operativeData.bizumContactEntity = [contactEntity]
        }
    }
    
    func removeContactEntity(_ identifier: String?) {
        guard let index = self.operativeData.bizumContactEntity?.firstIndex(where: {$0.identifier == identifier }) else { return }
        self.operativeData.bizumContactEntity?.remove(at: index)
    }
    
    func getHintContactValue() -> String {
        switch operativeData.bizumOperativeType {
        case .sendMoney:
            return "bizum_tooltip_writeAMobileNumber"
        case .requestMoney:
            return "bizum_tooltip_writeAMobileNumberRequest"
        case .donation:
            return ""
        }
    }
}

private extension BizumContactPresenter {
    var coordinator: BizumContactCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: BizumContactCoordinatorProtocol.self)
    }
    var globalPosition: GlobalPositionWithUserPrefsRepresentable {
        return self.dependenciesResolver.resolve(for: GlobalPositionWithUserPrefsRepresentable.self)
    }
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    var contactPermission: ContactPermissionsManagerProtocol {
        return dependenciesResolver.resolve(for: ContactPermissionsManagerProtocol.self)
    }
    
    func changeAccountSelected() {
        self.coordinator.goToAccountSelector(delegate: self)
    }
    
    func comparePhone(phone: String) -> Bool {
        guard let view = self.view else { return false }
        let phonesWithoutPrefix = view.arrayPhoneNumbers.map { $0.tlfWithoutPrefix() }
        return !phonesWithoutPrefix.contains(phone.tlfWithoutPrefix())
    }
    
    func handleContact() {
        let usecase: BizumOperationUseCaseAlias = self.dependenciesResolver.resolve()
        let input = BizumOperationUseCaseInput(page: 1,
                                               checkPayment: self.operativeData.bizumCheckPaymentEntity,
                                               orderBy: .dischargeDate,
                                               orderType: .descendant)
        UseCaseWrapper(with: usecase.setRequestValues(requestValues: input), useCaseHandler: self.useCaseHandler, onSuccess: { [weak self] response in
            guard let self = self else { return }
            let operations = response.operations
            if operations.isEmpty {
                self.view?.setEmptyContactFrequents()
            } else {
                let viewModel = self.getContactsViewModel(operations)
                viewModel.isEmpty ? self.view?.setEmptyContactFrequents() : self.view?.setContantFrequents(contacts: viewModel)
            }
        }, onError: { [weak self] _ in
            self?.view?.setEmptyContactFrequents()
        })
    }
    
    func getContactsViewModel(_ entities: [BizumOperationEntity]) -> [BizumFrequentViewModel] {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let phone = self.operativeData.bizumCheckPaymentEntity.phone?.trim()
        let models = entities
            .filter { $0.stateType != .validated && $0.stateType != .error }
            .filter { ($0.type == .request || $0.type == .send) && $0.emitterId == phone }
            .filter { $0.type != .donation }
            .reduce(NSMutableOrderedSet()) {
                let identifier = $1.receptorAlias ?? $1.receptorId ?? ""
                let colorType = colorsEngine.get(identifier)
                let alias = $1.receptorAlias?.capitalized
                let model = BizumFrequentViewModel(identifier: identifier,
                                                   name: alias,
                                                   phone: $1.receptorId?.tlfFormatted() ?? "",
                                                   avatarName: alias?.nameInitials ?? "",
                                                   avatarColor: ColorsByNameViewModel(colorType).color)
                $0.add(model)
                return $0
            }
        return Array(models) as? [BizumFrequentViewModel] ?? []
    }
    
    func getColorByName(_ identifier: String) -> ColorsByNameViewModel {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let colorType = colorsEngine.get(identifier)
        return ColorsByNameViewModel(colorType)
    }
    
    func updateContinueButton() {
        guard let view = self.view else { return }
        view.updateContinueAction(!view.arrayPhoneNumbers.isEmpty)
    }
    
    func addContacts() {
        guard var bizumContactsEntity = self.operativeData.bizumContactEntity else { return }
        bizumContactsEntity = Array(bizumContactsEntity.prefix(maxNumberContacts))
        bizumContactsEntity.enumerated().forEach { (index, contact) in
            self.view?.addContact(viewModel: BizumContactViewModel(
                                    identifier: contact.identifier,
                                    initials: contact.name?.nameInitials ?? "",
                                    name: contact.name,
                                    phone: contact.phone.tlfFormatted(),
                                    colorModel: self.getColorByName(contact.identifier),
                                    tag: index + 1,
                                    thumbnailData: contact.thumbnailData))
            self.checkIfNeedAddMoreContacts()
        }
    }
    
    func checkIfNeedAddMoreContacts() {
        guard let contacts = self.operativeData.bizumContactEntity,
              contacts.count < self.maxNumberContacts  else { return }
        self.view?.showAddContactView()
    }
}

extension BizumContactPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumContactPage {
        switch operativeData.bizumOperativeType {
        case .sendMoney:
            return BizumContactPage(strategy: BizumContactSendMoneyPage())
        case .requestMoney:
            return BizumContactPage(strategy: BizumContactRequestMoneyPage())
        case .donation:
            return BizumContactPage(strategy: BizumContactSendMoneyPage())
        }
    }
}

extension BizumContactPresenter: ContactListDelegate {
    func didContactSelected(viewModel: BizumContactListViewModel) {
        if self.comparePhone(phone: viewModel.phone) {
            let viewModelContact = BizumContactViewModel(identifier: viewModel.identifier,
                                                         initials: viewModel.initials,
                                                         name: viewModel.name ?? "",
                                                         phone: viewModel.phone,
                                                         colorModel: viewModel.colorModel,
                                                         tag: (self.operativeData.bizumContactEntity?.count ?? 0) + 1,
                                                         thumbnailData: viewModel.thumbnailData)
            self.addContactAndUpdateView(viewModelContact)
        }
    }
}

extension BizumContactPresenter: BizumSendMoneyAccountSelectorCoordinatorDelegate {
    func accountSelectorDidSelectAccount(_ account: AccountEntity) {
        self.operativeData.accountEntity = account
        self.showAccountHeader()
        self.container?.save(self.operativeData)
    }
}
