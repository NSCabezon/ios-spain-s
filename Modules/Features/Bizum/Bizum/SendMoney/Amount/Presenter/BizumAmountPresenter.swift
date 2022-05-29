import CoreFoundationLib
import Operative

protocol BizumAmountPresenterProtocol: ValidatableFormPresenterProtocol, OperativeStepPresenterProtocol {
    var view: BizumSendMoneyViewProtocol? { get set }
    func viewDidLoad()
    func didSelectContinue()
    func updateSendingAmount(_ amount: Decimal)
    func updateConcept(_ value: String)
    func didTapClose()
    func cameraWasTapped()
    func multipleViewShown()
    func simpleViewShown()
}

final class BizumAmountPresenter {
    var fields: [ValidatableField] = []
    var view: BizumSendMoneyViewProtocol?
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    var multimediaViewModel: BizumMultimediaViewModel?
    private let phoneFormatter = PhoneFormatter()
    private let dependenciesResolver: DependenciesResolver
    private var bizumSendMoney = BizumSendMoney.makeEmpty
    var strategy: AmountUseCaseStrategy?
    var useCase: AmountUseCases?
    private lazy var operativeData: BizumMoneyOperativeData? = {
        guard let container = self.container else { return nil }
        return container.get()
    }()
    private var userNoRegisterStrategy: UserNoRegisterStrategy?
    private var amountUseCaseStrategy: AmountUseCaseStrategy?

    lazy var photoHelper: PhotoHelper? = {
        let helper = PhotoHelper(delegate: self)
        helper.strategy = .compressionAndResize(maxBytes: 200000, imageSize: CGSize(width: 720, height: 720))
        return helper
    }()

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }

    func validatableFieldChanged() {
        view?.updateContinueAction(isValidForm)
    }
}

extension BizumAmountPresenter: BizumAmountPresenterProtocol {
    func viewDidLoad() {
        self.loadOperativeData()
        self.configureView()
        self.validatableFieldChanged()
    }

    func didSelectContinue() {
        if !(0.5 ... 1000).contains(self.bizumSendMoney.getAmount() ?? 0) {
            view?.showAmountError(localized("bizum_label_errorAmount"))
        } else {
            self.view?.hideAmountError()
            self.performSimpleOrMultipleUseCase()
        }
    }

    func updateSendingAmount(_ amount: Decimal) {
        self.bizumSendMoney.setAmount(amount)
        self.calculateTotalAmount()
    }

    func updateConcept(_ value: String) {
        self.bizumSendMoney.concept = value
    }

    func calculateTotalAmount() {
        guard let contacts = self.operativeData?.bizumContactEntity?.count,
              let amount = self.bizumSendMoney.getAmount() else { return }
        let totalAmount = (amount as NSDecimalNumber).multiplying(by: NSDecimalNumber(value: contacts)).decimalValue
        self.bizumSendMoney.setTotalAmount(totalAmount)
    }

    func didTapClose() {
        self.container?.close()
    }

    func multipleViewShown() {
        self.operativeData?.simpleMultipleType = BizumSimpleMultipleType.multiple
        self.trackScreen()
    }

    func simpleViewShown() {
        self.operativeData?.simpleMultipleType = BizumSimpleMultipleType.simple
        self.trackScreen()
    }
}

private extension BizumAmountPresenter {
    func configureView() {
        if let contacts = self.operativeData?.bizumContactEntity, contacts.count > 1 {
            self.makeAndShowMultipleSendMoney(contacts)
        } else {
            let viewModel = BizumSimpleAmountViewModel(operativeData?.bizumSendMoney)
            self.bizumSendMoney = operativeData?.bizumSendMoney ?? .makeEmpty
            self.view?.showSimpleSendMoney(viewModel)
        }
        if let multimediaViewModel = self.multimediaViewModel {
            self.view?.showMultimediaView(multimediaViewModel)
        }
    }

    func loadOperativeData() {
        self.multimediaViewModel = BizumMultimediaViewModel(multimediaData: self.operativeData?.multimediaData)
        self.bizumSendMoney = self.operativeData?.bizumSendMoney ?? .makeEmpty
        self.calculateTotalAmount()
    }

    func makeAndShowMultipleSendMoney(_ entities: [BizumContactEntity]) {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        guard let bizumOperativeType = self.operativeData?.bizumOperativeType,
            let contactsEntity = self.operativeData?.bizumContactEntity, contactsEntity.count > 1 else { return }
        let contactList = operativeData?.bizumContactEntity ?? []
        let contacts = contactList.map { (contact) -> BizumContactDetailModel in
            let colorType = colorsEngine.get(contact.identifier)
            let color = ColorsByNameViewModel(colorType)
            return BizumContactDetailModel(fullName: contact.name,
                                           initials: contact.name?.nameInitials,
                                           mobile: contact.phone.tlfFormatted(),
                                           color: color,
                                           thumbnailData: contact.thumbnailData)
        }
        view?.showMultipleSendMoney(bizumOperativeType,
                                    contacts: contacts,
                                    amount: operativeData?.bizumSendMoney?.amount.value,
                                    concept: operativeData?.bizumSendMoney?.concept)
    }

    func performSimpleOrMultipleUseCase() {
        if let contacts = self.operativeData?.bizumContactEntity, contacts.count > 1 {
            self.performMultipleSendMoneyUseCase()
        } else {
            self.performSimpleSendMoneyUseCase()
        }
    }

    func performSimpleSendMoneyUseCase() {
        guard let bizumOperativeType = operativeData?.bizumOperativeType,
              let document = self.operativeData?.document,
              let contacts = self.operativeData?.bizumContactEntity,
              let checkPayment = self.operativeData?.bizumCheckPaymentEntity,
              let receiverUserId = contacts.first?.phone,
              let phone = phoneFormatter.getNationalPhoneCodeTrimmed(phone: receiverUserId),
              let amount = self.bizumSendMoney.getAmount() else { return }
        switch bizumOperativeType {
        case .sendMoney:
            guard let operativeData = self.operativeData as? BizumSendMoneyOperativeData else { return }
            strategy = SendAmountUseCaseStrategy(dependenciesResolver: dependenciesResolver,
                                                 operativeData: operativeData,
                                                 checkPayment: checkPayment,
                                                 document: document,
                                                 concept: self.bizumSendMoney.concept,
                                                 amount: amount.getStringValue(),
                                                 receivers: [phone],
                                                 account: self.operativeData?.accountEntity)
        case .requestMoney:
            guard let operativeData = self.operativeData as? BizumRequestMoneyOperativeData else { return }
            strategy = RequestAmountUseCaseStrategy(dependenciesResolver: dependenciesResolver,
                                                    operativeData: operativeData,
                                                    checkPayment: checkPayment,
                                                    document: document,
                                                    concept: self.bizumSendMoney.concept,
                                                    amount: amount.getStringValue(),
                                                    receivers: [phone])
        case .donation:
            return
        }
        guard let safeStrategy = strategy else { return }
        useCase = AmountUseCases(strategy: safeStrategy)
        view?.showLoading()
        useCase?.executeSimpleAmountUseCase { [weak self] in
            self?.view?.dismissLoading(completion: { [weak self] in
                self?.updateSendMoneyOperativeData()
                self?.checkIfUserRegistered()
            })
        } onFailure: { [weak self] error in
            self?.view?.dismissLoading(completion: { [weak self] in
                self?.view?.showErrorMessage(key: error ?? "generic_error_txt")
            })
        }
    }

    func performMultipleSendMoneyUseCase() {
        guard let bizumOperativeType = operativeData?.bizumOperativeType,
              let contacts = self.operativeData?.bizumContactEntity,
              let checkPayment = self.operativeData?.bizumCheckPaymentEntity,
              let document = self.operativeData?.document,
              let amount = self.bizumSendMoney.getAmount() else { return }
        let phones: [String] = contacts.map({ (phoneFormatter.getNationalPhoneCodeTrimmed(phone: $0.phone) ?? "") })
        switch bizumOperativeType {
        case .sendMoney:
            guard let operativeData = self.operativeData as? BizumSendMoneyOperativeData else { return }
            strategy = SendAmountUseCaseStrategy(dependenciesResolver: dependenciesResolver,
                                                 operativeData: operativeData,
                                                 checkPayment: checkPayment,
                                                 document: document,
                                                 concept: self.bizumSendMoney.concept,
                                                 amount: amount.getStringValue(),
                                                 receivers: phones,
                                                 account: self.operativeData?.accountEntity)
        case .requestMoney:
            guard let operativeData = self.operativeData as? BizumRequestMoneyOperativeData else { return }
            strategy = RequestAmountUseCaseStrategy(dependenciesResolver: dependenciesResolver,
                                                    operativeData: operativeData,
                                                    checkPayment: checkPayment,
                                                    document: document,
                                                    concept: self.bizumSendMoney.concept,
                                                    amount: amount.getStringValue(),
                                                    receivers: phones)
        case .donation:
            return
        }
        guard let safeStrategy = strategy else { return }
        useCase = AmountUseCases(strategy: safeStrategy)
        view?.showLoading()
        useCase?.executeMultipleAmountUseCase { [weak self] in
            self?.view?.dismissLoading(completion: { [weak self] in
                self?.updateSendMoneyOperativeData()
                self?.saveOperativeDataAndContinue()
            })
        } onFailure: { [weak self] error in
            self?.view?.dismissLoading(completion: { [weak self] in
                self?.view?.showErrorMessage(key: error ?? "generic_error_txt")
            })
        }
    }

    func updateSendMoneyOperativeData() {
        self.operativeData?.bizumSendMoney = self.bizumSendMoney
    }

    func checkIfUserRegistered() {
        if self.operativeData?.typeUserInSimpleSend == .register {
            self.saveOperativeDataAndContinue()
        } else {
            self.trackToolTips()
            self.showAlertUserIsNotRegistered()
        }
    }

    func showAlertUserIsNotRegistered() {
        self.view?.showBizumNonRegistered(onAccept: { [weak self] in
            self?.didTapOnAcceptInviteUser()
        }, onCancel: { [weak self] in
            self?.operativeData?.bizumContactEntity = []
            self?.operativeData?.bizumSendMoney = nil
            self?.container?.back(to: BizumContactPresenter.self)
        })
    }

    func didTapOnAcceptInviteUser() {
        guard let bizumOperativeType = operativeData?.bizumOperativeType else { return }
        switch bizumOperativeType {
        case .sendMoney:
            userNoRegisterStrategy = SendUserNoRegisterStrategy(dependenciesResolver: self.dependenciesResolver,
                                                                container: self.container,
                                                                operativeData: self.operativeData as? BizumSendMoneyOperativeData)
        case .requestMoney:
            userNoRegisterStrategy = RequestUserNoRegisterStrategy(dependenciesResolver: self.dependenciesResolver,
                                                                   operativeData: operativeData as? BizumRequestMoneyOperativeData)
        case .donation:
            return
        }
        guard let userNoRegisterStrategy = userNoRegisterStrategy else { return }
        let useCase = UserNoRegisteredUseCase(strategy: userNoRegisterStrategy)
        self.view?.showLoading()
        useCase.executeUserNotRegister { [weak self] in
            self?.view?.dismissLoading(completion: { [weak self] in
                self?.saveOperativeDataAndContinue()
            })
        } onFailure: { [weak self] error in
            self?.view?.dismissLoading(completion: { [weak self] in
                self?.inviteUseCaseFailure(error: error)
            })
        }
    }

    func saveOperativeDataAndContinue() {
        self.operativeData?.multimediaData = self.multimediaViewModel?.multimediaData
        self.container?.save(self.operativeData)
        self.container?.rebuildSteps()
        self.container?.stepFinished(presenter: self)
    }

    func inviteUseCaseFailure(error: String?) {
        guard let bizumOperativeType = operativeData?.bizumOperativeType else { return }
        switch bizumOperativeType {
        case .sendMoney:
            self.view?.showErrorMessage(key: error ?? "generic_error_txt")
        case .requestMoney:
            self.view?.showDialog(withDependenciesResolver: self.dependenciesResolver,
                                  description: error)
        case .donation:
            return
        }
    }
}

extension BizumAmountPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }

    var trackerPage: BizumAmountPage {
        guard let bizumOperativeType = operativeData?.bizumOperativeType else { return BizumAmountPage(strategy: nil) }
        let pageAssociated: TrackerPageAssociated
        switch bizumOperativeType {
        case .sendMoney:
            pageAssociated = BizumAmountSendMoneyPage()
        case .requestMoney:
            pageAssociated = BizumAmountRequestMoneyPage()
        case .donation:
            pageAssociated = BizumDonationAmountPage()
        }
        return BizumAmountPage(strategy: pageAssociated)

    }

    func trackToolTips() {
        guard let bizumOperativeType = operativeData?.bizumOperativeType else { return }
        let page: String
        switch bizumOperativeType {
        case .sendMoney:
            page = BizumNoRegisterToolTipSendMoneyPage().page
        case .requestMoney:
            page = BizumNoRegisterToolTipRequestMoneyPage().page
        case .donation:
            return
        }
        self.trackerManager.trackScreen(screenId: page, extraParameters: [:])
    }
    
    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.simpleMultipleType.key: self.operativeData?.simpleMultipleType?.rawValue ?? ""
        ]
    }
}
