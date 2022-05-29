//
//  BizumSplitExpensesAmountPresenter.swift
//  Bizum

import CoreFoundationLib
import Operative
import SANLibraryV3

protocol BizumSplitExpensesContactPresenterProtocol {
    func didSelectAcceptWithPhone(_ phone: String)
    func didSelectAddMoreContacts()
    func removeContact(identifier: String?)
    func trackRemoveContact()
    func didSelectPhoneBook()
    func didSelectFrequentContacts(_ viewModel: BizumFrequentViewModel?)
    func didAllowPermission()
}

protocol BizumSplitExpensesAmountPresenterProtocol: OperativeStepPresenterProtocol, BizumSplitExpensesContactPresenterProtocol {
    var view: BizumSplitExpensesAmountViewProtocol? { get set }
    func viewDidLoad()
    func viewWillAppear()
    func didSelectContinue()
    func didTapClose()
    func cameraWasTapped()
    func multipleViewShown()
    func simpleViewShown()
    func selectedImage(image: Data)
    func conceptUpdated(_ concept: String)
}

final class BizumSplitExpensesAmountPresenter {
    weak var view: BizumSplitExpensesAmountViewProtocol?
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    var multimediaViewModel: BizumMultimediaViewModel?
    private var concept: String?
    
    private let maxNumberContacts: Int = 30
    private let dependenciesResolver: DependenciesResolver
    private var contacts: [BizumContactEntity] {
        return self.operativeData?.bizumContactEntity ?? []
    }
    private lazy var operativeData: BizumSplitExpensesOperativeData? = {
        guard let container = self.container else { return nil }
        return container.get()
    }()
    private lazy var photoHelper: PhotoHelper? = {
        guard let view = self.view else { return nil }
        let helper = PhotoHelper(delegate: view)
        helper.strategy = .compressionAndResize(maxBytes: 200000, imageSize: CGSize(width: 720, height: 720))
        return helper
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumSplitExpensesAmountPresenter: BizumSplitExpensesAmountPresenterProtocol {
    func viewDidLoad() {
        self.configureTransaction()
        self.loadFrequentContacts()
        let multimediaViewModel = BizumMultimediaViewModel(multimediaData: self.operativeData?.multimediaData)
        self.multimediaViewModel = multimediaViewModel
        self.view?.showMultimediaView(multimediaViewModel)
        self.configureTransaction()
        self.view?.updateContinueAction(true)
    }
    
    func viewWillAppear() {
        self.reloadContacts()
    }
    
    func addLocalUserContact() {
        guard let operativeData = self.operativeData, let sendMoney = operativeData.bizumSendMoney else { return }
        let phoneFormatter = PhoneFormatter()
        var identifier = ""
        if let phoneNumber = operativeData.bizumCheckPaymentEntity.phone {
            identifier = phoneFormatter.getNationalPhoneCodeTrimmed(phone: phoneNumber) ?? ""
        }
        let meText: String = localized("bizum_label_me")
        let contactModel = SplitTransactionContactViewModel(
            identifier: identifier,
            initials: meText.nameInitials,
            name: meText,
            phone: identifier,
            colorModel: self.getColorByName(identifier),
            tag: 0,
            splittedAmount: sendMoney.amount,
            isDeviceUser: true,
            showPlainSeparatorView: true,
            thumbnailData: nil
        )
        self.view?.addContact(viewModel: contactModel)
        self.view?.showAddMoreContactsView()
    }
    
    func configureTransaction() {
        guard let operativeData = self.operativeData else { return }
        let viewModel = SplitTransactionViewModel(
            title: TextWithAccessibility(
                text: operativeData.operation.concept.camelCasedString,
                accessibility: "lbl_concept"
            ),
            amount: operativeData.operation.amount,
            amountAccessibility: "lbl_amount",
            origin: TextWithAccessibility(
                text: operativeData.operation.productAlias,
                accessibility: "lbl_product_alias"
            )
        )
        self.view?.showTransaction(viewModel)
    }
    
    func didSelectContinue() {
        switch self.contacts.count {
        case 0: self.view?.showNotSplittableError()
        case 1: self.performRequestMoney()
        default: self.performRequestMoneyMulti()
        }
    }
    
    func didTapClose() {
        self.container?.close()
    }
    
    func cameraWasTapped() {
        self.view?.showOptionsToAddImage(onCamera: {
            self.photoHelper?.askImage(type: .camera)
        }, onGallery: {
            self.photoHelper?.askImage(type: .photoLibrary)
        })
    }
    
    func multipleViewShown() {
        
    }
    
    func simpleViewShown() {
        
    }
    
    func selectedImage(image: Data) {
        self.multimediaViewModel?.showThumbnailImage(image)
    }
    
    func conceptUpdated(_ concept: String) {
        self.concept = concept
    }
}

private extension BizumSplitExpensesAmountPresenter {
    
    var requestMoneyUseCase: BizumValidateRequestMoneyUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    var requestMoneyMultiUseCase: BizumValidateRequestMoneyMultiUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    var inviteClientUseCase: BizumRequestMoneyInviteClientUseCase {
        return self.dependenciesResolver.resolve()
    }
    
    func performRequestMoney() {
        guard let operativeData = self.operativeData,
              let document = operativeData.document,
              let amount = operativeData.bizumSendMoney?.getAmount() else { return }
        let input = BizumValidateRequestMoneyUseCaseInput(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            document: document,
            dateTime: Date(),
            concept: self.concept ?? "",
            amount: amount.getStringValue(),
            receiverUserId: self.contacts.first?.phone ?? ""
        )
        self.view?.showLoading()
        let scenario = Scenario(useCase: self.requestMoneyUseCase, input: input)
        scenario
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess(self.handleRequestMoneySuccessfullResponse)
            .onError(self.handleRequestMoneyErrorResponse)
    }
    
    func handleRequestMoneySuccessfullResponse(_ response: BizumValidateRequestMoneyUseCaseOkOutput) {
        self.operativeData?.simpleMultipleType = .simple
        self.operativeData?.typeUserInSimpleSend = response.userRegistered == true ? .register : .noRegister
        self.operativeData?.bizumValidateMoneyRequestEntity = response.validateMoneyRequestEntity
        self.view?.dismissLoading {
            if response.userRegistered == false {
                self.trackerManager.trackScreen(screenId: BizumSplitExpensesInvitation.page, extraParameters: [:])
                self.view?.showBizumNonRegistered(
                    onAccept: {
                        self.performInviteUser(validateMoneyRequestEntity: response.validateMoneyRequestEntity)
                        self.trackerManager.trackEvent(screenId: BizumSplitExpensesInvitation.page, eventId: BizumSplitExpensesInvitation.Action.invite, extraParameters: [:])
                    },
                    onCancel: nil
                )
            } else {
                self.saveOperativeDataAndContinue()
            }
        }
    }
    
    func handleRequestMoneyErrorResponse(_ error: UseCaseError<StringErrorOutput>) {
        self.view?.dismissLoading {
            self.view?.showErrorMessage(key: error.getErrorDesc() ?? "")
        }
    }
    
    func performRequestMoneyMulti() {
        guard let operativeData = self.operativeData, let document = operativeData.document, let amount = operativeData.bizumSendMoney?.getAmount() else { return }
        let input = BizumValidateRequestMoneyMultiUseCaseInput(
            checkPayment: operativeData.bizumCheckPaymentEntity,
            document: document,
            dateTime: Date(),
            concept: self.concept ?? "",
            amount: amount.getStringValue(),
            receiversUserIds: self.contacts.map({ $0.phone })
        )
        self.view?.showLoading()
        let scenario = Scenario(useCase: self.requestMoneyMultiUseCase, input: input)
        scenario
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess(self.handleRequestMoneyMultiSuccessfullResponse)
            .onError(self.handleRequestMoneyMultiErrorResponse)
    }
    
    func dismissLoading() {
        self.view?.dismissLoading()
    }
    
    func handleRequestMoneyMultiSuccessfullResponse(_ response: BizumValidateRequestMoneyMultiUseCaseOkOutput) {
        self.view?.dismissLoading {
            self.operativeData?.simpleMultipleType = .multiple
            self.operativeData?.bizumValidateMoneyRequestMultiEntity = response.validateMoneyRequestMultiEntity
            self.saveOperativeDataAndContinue()
        }
    }
    
    func handleRequestMoneyMultiErrorResponse(_ error: UseCaseError<StringErrorOutput>) {
        self.view?.dismissLoading {
            self.view?.showErrorMessage(key: error.getErrorDesc() ?? "")
        }
    }
    
    func performInviteUser(validateMoneyRequestEntity: BizumValidateMoneyRequestEntity) {
        let input = BizumRequestMoneyInviteClientUseCaseInput(validateMoneyRequestEntity: validateMoneyRequestEntity)
        let scenario = Scenario(useCase: self.inviteClientUseCase, input: input)
        self.view?.showLoading()
        scenario
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess(self.handleInviteUserSuccessfullResponse)
            .onError(self.handleInviteUserErrorResponse)
    }
    
    func handleInviteUserSuccessfullResponse() {
        self.view?.dismissLoading {
            self.saveOperativeDataAndContinue()
        }
    }
    
    func handleInviteUserErrorResponse(_ error: UseCaseError<StringErrorOutput>) {
        self.view?.dismissLoading {
            self.view?.showErrorMessage(key: error.getErrorDesc() ?? "")
        }
    }
    
    func saveOperativeDataAndContinue() {
        self.operativeData?.concept = self.concept
        self.operativeData?.multimediaData = self.multimediaViewModel?.multimediaData
        self.container?.save(self.operativeData)
        self.container?.rebuildSteps()
        self.container?.stepFinished(presenter: self)
    }
}

// MARK: - Contacts extensions
extension BizumSplitExpensesAmountPresenter: BizumSplitExpensesContactPresenterProtocol {
    func didSelectAcceptWithPhone(_ phone: String) {
        guard isValidForm else { self.view?.updateAcceptAction(false); return }
        guard comparePhone(phone: phone) else { return }
        let phoneFormatter = PhoneFormatter()
        let identifier = phoneFormatter.getNationalPhoneCodeTrimmed(phone: phone) ?? ""
        let viewModel = SplitTransactionContactViewModel(identifier: identifier, initials: nil, name: nil, phone: phone, colorModel: self.getColorByName(identifier),
                                                         tag: (self.operativeData?.bizumContactEntity?.count ?? 0) + 1, splittedAmount: AmountEntity(value: 0.0),
                                                         thumbnailData: nil)
        self.addContactAndUpdateView(viewModel)
        self.trackEvent(.addNewManuallyTypedNumber, parameters: [:])
    }
    
    func didSelectAddMoreContacts() {
        guard let view = self.view else { return }
        view.addContactsInputArea()
        self.trackEvent(.addMoreContacts, parameters: [:])
    }
    
    func removeContact(identifier: String?) {
        self.removeContactEntity(identifier)
        if let ownAmount = self.operativeData?.ownAmount, let remainingContactsAmount = self.operativeData?.bizumSendMoney?.amount {
            self.view?.reloadSplittedAmountBetweenContacts(ownAmount: ownAmount, remainingContactsAmount: remainingContactsAmount)
        }
        self.checkIfNeedAddMoreContacts()
        self.trackEvent(.removeContact, parameters: [:])
    }
    
    func trackRemoveContact() {
        self.trackEvent(.confirmRemoveContact, parameters: [:])
    }
    
    func didSelectPhoneBook() {
        let presenter = ContactListPresenter(dependenciesResolver: self.dependenciesResolver)
        presenter.delegate = self
        if self.contactPermission.isContactsAccessEnabled() {
            self.view?.showPhoneBook(with: presenter)
        } else {
            self.view?.showPhoneBookAccessAlert()
        }
        self.trackEvent(.phoneBook, parameters: [:])
    }
    
    func didSelectFrequentContacts(_ viewModel: BizumFrequentViewModel?) {
        guard let viewModel = viewModel, self.view != nil else { return }
        if self.comparePhone(phone: viewModel.phone) {
            let identifier = viewModel.name ?? viewModel.identifier ?? ""
            let contact = SplitTransactionContactViewModel(identifier: identifier,
                                                           initials: viewModel.avatarName,
                                                           name: viewModel.name,
                                                           phone: viewModel.phone,
                                                           colorModel: getColorByName(identifier),
                                                           tag: (self.operativeData?.bizumContactEntity?.count ?? 0) + 1,
                                                           splittedAmount: AmountEntity(value: 0.0),
                                                           thumbnailData: nil)
            self.trackEvent(.frequentContact, parameters: [:])
            self.addContactAndUpdateView(contact)
        } else {
            self.view?.duplicatePhone()
            self.checkIfNeedAddMoreContacts()
        }
    }
    
    func didAllowPermission() {
        let presenter = ContactListPresenter(dependenciesResolver: self.dependenciesResolver)
        presenter.delegate = self
        self.contactPermission.isAlreadySet { [weak self] isAlreadySet in
            guard let self = self else { return }
            if isAlreadySet {
                self.view?.showPhoneBookAccessPermissionDialog()
            } else {
                self.contactPermission.askAuthorizationIfNeeded { authorized in
                    if authorized {
                        self.view?.showPhoneBook(with: presenter)
                    }
                }
            }
        }
    }
}

private extension BizumSplitExpensesAmountPresenter {
    
    var isValidForm: Bool {
        guard let view = self.view, let phone = view.phoneString
        else { return false }
        let phoneFormatter = PhoneFormatter()
        let phoneFormatted = phoneFormatter.checkNationalPhone(phone: phone) == PhoneTextFiledResult.ok
        return phoneFormatted && self.comparePhone(phone: phone)
    }
    
    var bizumOperationUseCase: BizumOperationUseCaseAlias {
        return self.dependenciesResolver.resolve(for: BizumOperationUseCaseAlias.self)
    }
    
    var useCaseHandler: UseCaseHandler {
        return self.dependenciesResolver.resolve(for: UseCaseHandler.self)
    }
    
    var contactPermission: ContactPermissionsManagerProtocol {
        return dependenciesResolver.resolve(for: ContactPermissionsManagerProtocol.self)
    }
    
    func reloadContacts() {
        self.view?.removeAllContacts()
        self.addLocalUserContact()
        if let bizumContactEntity = self.operativeData?.bizumContactEntity, !bizumContactEntity.isEmpty {
            self.addContacts()
            if let ownAmount = self.operativeData?.ownAmount, let remainingContactsAmount = self.operativeData?.bizumSendMoney?.amount {
                self.view?.reloadSplittedAmountBetweenContacts(ownAmount: ownAmount, remainingContactsAmount: remainingContactsAmount)
            }
        } else {
            self.view?.showAddMoreContactsView()
        }
    }
    
    func loadFrequentContacts() {
        guard let checkPaymentEntity = self.operativeData?.bizumCheckPaymentEntity else {
            self.view?.setEmptyFrequentContacts()
            return
        }
        
        let input = BizumOperationUseCaseInput(page: 1,
                                               checkPayment: checkPaymentEntity,
                                               orderBy: .dischargeDate,
                                               orderType: .descendant)
        Scenario(useCase: self.bizumOperationUseCase, input: input)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                guard let self = self else { return }
                let operations = response.operations
                if operations.isEmpty {
                    self.view?.setEmptyFrequentContacts()
                } else {
                    let viewModel = self.getContactsViewModel(operations)
                    viewModel.isEmpty ? self.view?.setEmptyFrequentContacts() : self.view?.setFrequentContacts(contacts: viewModel)
                }
            }
            .onError { [weak self] _ in
                self?.view?.setEmptyFrequentContacts()
            }
    }
    
    func addContacts() {
        guard var bizumContactsEntity = self.operativeData?.bizumContactEntity else { return }
        bizumContactsEntity = Array(bizumContactsEntity.prefix(maxNumberContacts))
        bizumContactsEntity.enumerated().forEach { (index, contact) in
            self.view?.addContact(viewModel: SplitTransactionContactViewModel(
                                    identifier: contact.identifier,
                                    initials: contact.name?.nameInitials ?? "",
                                    name: contact.name,
                                    phone: contact.phone.tlfFormatted(),
                                    colorModel: self.getColorByName(contact.identifier),
                                    tag: index + 1,splittedAmount: AmountEntity(value: 0.0),
                                    thumbnailData: contact.thumbnailData))
            self.checkIfNeedAddMoreContacts()
        }
    }
    
    func getContactsViewModel(_ entities: [BizumOperationEntity]) -> [BizumFrequentViewModel] {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let phone = self.operativeData?.bizumCheckPaymentEntity.phone?.trim()
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
    
    func checkIfNeedAddMoreContacts() {
        guard let contacts = self.operativeData?.bizumContactEntity,
              contacts.count < self.maxNumberContacts  else { return }
        self.view?.showAddMoreContactsView()
    }
    
    func comparePhone(phone: String) -> Bool {
        guard let view = self.view else { return false }
        let phonesWithoutPrefix = view.phoneNumbersArray.map { $0.tlfWithoutPrefix() }
        if phonesWithoutPrefix.contains(phone.tlfWithoutPrefix()) {
            return false
        } else {
            return true
        }
    }
    
    func removeContactEntity(_ identifier: String?) {
        guard let index = self.operativeData?.bizumContactEntity?.firstIndex(where: { $0.identifier == identifier }) else { return }
        self.operativeData?.bizumContactEntity?.remove(at: index)
    }
    
    // MARK: Add contact to split operation contacts list
    func addContactAndUpdateView(_ contact: SplitTransactionContactViewModel) {
        self.view?.addContact(viewModel: contact)
        self.addContactEntity(contact)
        if let ownAmount = self.operativeData?.ownAmount, let remainingContactsAmount = self.operativeData?.bizumSendMoney?.amount {
            self.view?.reloadSplittedAmountBetweenContacts(ownAmount: ownAmount, remainingContactsAmount: remainingContactsAmount)
        }
        self.checkIfNeedAddMoreContacts()
    }
    
    func addContactEntity(_ contact: SplitTransactionContactViewModel) {
        let formatter = PhoneFormatter()
        let contactEntity = BizumContactEntity(
            identifier: contact.identifier ?? "",
            name: contact.name,
            phone: formatter.getNationalPhoneCodeTrimmed(phone: contact.phone) ?? "",
            validateSendAction: localized("confirmation_label_request"),
            thumbnailData: contact.thumbnailData
        )
        if self.operativeData?.bizumContactEntity != nil {
            self.operativeData?.bizumContactEntity?.append(contactEntity)
        } else {
            self.operativeData?.bizumContactEntity = [contactEntity]
        }
    }
}

extension BizumSplitExpensesAmountPresenter: ContactListDelegate {
    func didContactSelected(viewModel: BizumContactListViewModel) {
        if self.comparePhone(phone: viewModel.phone) {
            let viewModelContact = SplitTransactionContactViewModel(
                identifier: viewModel.identifier,
                initials: viewModel.initials,
                name: viewModel.name ?? "",
                phone: viewModel.phone,
                colorModel: viewModel.colorModel,
                tag: (self.operativeData?.bizumContactEntity?.count ?? 0) + 1, splittedAmount: AmountEntity(value: 0.0),
                thumbnailData: viewModel.thumbnailData
            )
            self.addContactAndUpdateView(viewModelContact)
        }
    }
}

extension BizumSplitExpensesAmountPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumSplitExpensesAmountPage {
        BizumSplitExpensesAmountPage()
    }
}
