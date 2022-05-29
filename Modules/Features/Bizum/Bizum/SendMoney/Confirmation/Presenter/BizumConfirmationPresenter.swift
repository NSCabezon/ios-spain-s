import CoreFoundationLib
import Operative
import BiometryValidator

protocol BizumConfirmationPresenterProtocol: OperativeConfirmationPresenterProtocol {
    var view: BizumConfirmationViewProtocol? { get set }
    func viewDidLoad()
    func didTapClose()
    func getContacts()
    func didSelectBiometricValidationButton()
}

extension BizumConfirmationPresenterProtocol {
    func didSelectBiometricValidationButton() {}
}

final class BizumConfirmationPresenter {
    var view: BizumConfirmationViewProtocol?
    // MARK: - OperativeStepPresenterProtocol
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?

    // MARK: - Internal Attributes
    internal var dependenciesResolver: DependenciesResolver
    internal lazy var operativeData: BizumSendMoneyOperativeData? = {
        guard let container = self.container else { return nil }
        return container.get()
    }()
    internal lazy var validateBiometryTransferStateOTP: ValidateBiometryTransferOTP? = {
        guard let operativeData = self.operativeData,
              let container = self.container else { return nil }
        return ValidateBiometryTransferOTP(
            dependenciesResolver: dependenciesResolver,
            operativeData: operativeData,
            container: container)
    }()

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func viewDidLoad() {
        self.trackScreen()
        self.updateBizumContactEntity()
        self.loadData()
        if let operativeData = self.operativeData, operativeData.isBiometricValidationEnable,
           let type = operativeData.simpleMultipleType {
            self.view?.addBiometricValidationButton()
            self.updateValidateTransfer(with: type)
        } else {
            self.view?.setContinueTitle(localized("generic_button_send"))
        }
    }
}

extension BizumConfirmationPresenter: BizumConfirmationPresenterProtocol {
    func modifyAmount() {
        self.container?.back(to: BizumAmountPresenter.self)
    }
    func modifyContacts() {
        self.container?.back(to: BizumContactPresenter.self)
    }

    func getContacts() {
        guard let contacts = self.operativeData?.bizumContactEntity,
              let amount = self.operativeData?.bizumSendMoney?.amount
        else { return }
        // When there is one contact, don't draw the amount
        let viewModels = contacts.map { ConfirmationContactDetailViewModel(identifier: $0.identifier,
                                                                           name: $0.name,
                                                                           alias: $0.alias,
                                                                           initials: $0.name?.nameInitials,
                                                                           phone: $0.phone,
                                                                           amount: contacts.count == 1 ? nil : amount,
                                                                           validateSendAction: $0.validateSendAction?.capitalized,
                                                                           colorModel: self.getColorByName($0.identifier),
                                                                           thumbnailData: $0.thumbnailData) }
        self.view?.setContacts(viewModels)
    }
    
    func didTapClose() {
        self.container?.close()
    }

    // MARK: Continue button actions
    func didSelectContinue() {
        self.view?.showLoading()
        self.performSignaturePositionUseCase { [weak self] in
            guard let self = self else { return}
            self.view?.dismissLoading(completion: {
                self.container?.rebuildSteps()
                self.container?.stepFinished(presenter: self)
            })
        }
    }

    func didSelectBiometricValidationButton() {
        self.coordinator.openBiometricValidation(delegate: self)
    }

    func performSignaturePositionUseCase(onSuccess: @escaping () -> Void) {
        Scenario(useCase: self.signPosUseCase)
            .execute(on: dependenciesResolver.resolve())
            .onSuccess { [weak self] response in
                guard let self = self else { return }
                self.container?.save(self.operativeData)
                self.container?.save(response.signatureWithTokenEntity)
                onSuccess()
            }
            .onError { [weak self] error in
                guard let self = self else { return }
                self.view?.dismissLoading(completion: {
                    self.view?.showDialog(
                        withDependenciesResolver: self.dependenciesResolver,
                        description: error.getErrorDesc()
                    )
                })
            }
    }
}

private extension BizumConfirmationPresenter {
    var coordinator: BizumConfirmationCoordinatorProtocol {
        return dependenciesResolver.resolve(for: BizumConfirmationCoordinatorProtocol.self)
    }

    var signPosUseCase: SignPosSendMoneyUseCase {
        return dependenciesResolver.resolve(for: SignPosSendMoneyUseCase.self)
    }

    func loadData() {
        guard let data = self.operativeData else { return }
        let builder = BizumSendMoneyConfirmationBuilder(data: data, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept(action: modifyAmount)
        builder.addMedia()
        builder.addOriginAccount(action: modifyContacts)
        builder.addTransferType()
        builder.addContacts(action: modifyContacts)
        builder.addTotal()
        self.view?.add(builder.build())
    }
    
    func updateBizumContactEntity() {
        guard let data = self.operativeData,
              let contacts = data.bizumContactEntity,
              var firstContact = contacts.first else { return }
        if contacts.count == 1 {
            guard let simpleEntity = data.bizumValidateMoneyTransferEntity else { return }
            firstContact.addAliasIsBizum(alias: simpleEntity.beneficiaryAlias,
                                         validateSendAction: simpleEntity.transferInfo.errorCode == "0" ?
                                            localized("confirmation_label_send") :
                                            localized("confirmation_label_invite"))
            data.bizumContactEntity = [firstContact]
        } else {
            guard let multipleEntity = data.bizumValidateMoneyTransferMultiEntity else { return }
            var result = [BizumContactEntity]()
            contacts.forEach { contact in
                for response in multipleEntity.validationResponseList where response.identifier == contact.phone {
                    result.append(BizumContactEntity(identifier: contact.identifier,
                                                     name: contact.name,
                                                     phone: contact.phone,
                                                     alias: response.beneficiaryAlias,
                                                     validateSendAction: response.action,
                                                     thumbnailData: contact.thumbnailData))
                }
            }
            data.bizumContactEntity = result
        }
    }
    
    func getColorByName(_ identifier: String) -> ColorsByNameViewModel {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let colorType = colorsEngine.get(identifier)
        return ColorsByNameViewModel(colorType)
    }

    func updateValidateTransfer(with type: BizumSimpleMultipleType) {
        guard let operativeData = self.operativeData,
              let container = self.container else { return }
        switch type {
        case .simple:
            let simpleState = ValidateSimpleTransferOTP(
                dependenciesResolver: dependenciesResolver,
                operativeData: operativeData,
                container: container,
                otpCode: ""
            )
            validateBiometryTransferStateOTP?.update(state: simpleState)
        case.multiple:
            let multipleState = ValidateMultiTransferOTP(
                dependenciesResolver: dependenciesResolver,
                operativeData: operativeData,
                container: container,
                otpCode: ""
            )
            validateBiometryTransferStateOTP?.update(state: multipleState)
        }
    }
}

extension BizumConfirmationPresenter: AutomaticScreenActionTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumSendMoneyConfirmationPage {
        return BizumSendMoneyConfirmationPage()
    }

    func getTrackParameters() -> [String: String]? {
        return [
            TrackerDimension.simpleMultipleType.key: self.operativeData?.simpleMultipleType?.rawValue ?? ""
        ]
    }
}
