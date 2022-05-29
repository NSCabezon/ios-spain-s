import Foundation
import Operative
import CoreFoundationLib

protocol BizumDonationAmountPresenterProtocol: OperativeStepPresenterProtocol, ValidatableFormPresenterProtocol {
    var view: BizumDonationAmountViewProtocol? { get set }
    func viewDidLoad()
    func didSelectContinue()
    func didSelectClose()
    func cameraWasTapped()
    func selectedImage(image: Data)
    func updateAmount(_ amount: Decimal)
    func updateConcept(_ value: String)
}

final class BizumDonationAmountPresenter {
    var view: BizumDonationAmountViewProtocol?
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = true
    var container: OperativeContainerProtocol?
    var bizumSendMoney: BizumSendMoney?
    var multimediaViewModel: BizumMultimediaViewModel?
    var fields: [ValidatableField] = []
    internal let dependenciesResolver: DependenciesResolver
    private lazy var operativeData: BizumDonationOperativeData? = {
        guard let container = self.container else { return nil }
        return container.get()
    }()
    private lazy var photoHelper: PhotoHelper? = {
        guard let view = self.view else { return nil }
        let helper = PhotoHelper(delegate: view)
        helper.strategy = .compressionAndResize(maxBytes: 300000, imageSize: CGSize(width: 720, height: 720))
        return helper
    }()

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension BizumDonationAmountPresenter: BizumDonationAmountPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.showAccountHeader()
        self.setupDestination()
        self.setupAmountView()
        self.setupMultimediaView()
    }

    func didSelectContinue() {
        if !(0.5 ... 1000).contains(self.bizumSendMoney?.getAmount() ?? 0) {
            self.view?.showAmountError(localized("bizum_label_errorAmount"))
        } else {
            self.view?.hideAmountError()
            self.performSimpleSendMoneyUseCase()
        }
    }

    func didSelectClose() {
        self.container?.close()
    }

    func cameraWasTapped() {
        self.view?.showOptionsToAddImage(onCamera: {
            self.photoHelper?.askImage(type: .camera)
        }, onGallery: {
            self.photoHelper?.askImage(type: .photoLibrary)
        })
    }

    func selectedImage(image: Data) {
        self.multimediaViewModel?.showThumbnailImage(image)
    }

    func validatableFieldChanged() {
        self.view?.updateContinueAction(isValidForm)
        self.view?.hideAmountError()
    }

    func updateAmount(_ amount: Decimal) {
        self.bizumSendMoney?.amount = AmountEntity(value: amount)
        self.bizumSendMoney?.totalAmount = AmountEntity(value: amount)
    }

    func updateConcept(_ value: String) {
        self.bizumSendMoney?.concept = value
    }
}

extension BizumDonationAmountPresenter: BizumSendMoneyAccountSelectorCoordinatorDelegate {
    func accountSelectorDidSelectAccount(_ account: AccountEntity) {
        self.operativeData?.accountEntity = account
        self.showAccountHeader()
        self.container?.save(self.operativeData)
    }
}
private extension BizumDonationAmountPresenter {
    var coordinator: BizumDonationAmountCoordinatorProtocol {
        return self.dependenciesResolver.resolve(for: BizumDonationAmountCoordinatorProtocol.self)
    }

    func showAccountHeader() {
        guard let account = self.operativeData?.accountEntity else { return }
        let viewModel: SelectAccountHeaderViewModel = SelectAccountHeaderViewModel(account: account,
                                                                                   title: localized("bizum_label_bizumAccount").text,
                                                                                   accessibilityIdTitle: "",
                                                                                   action: self.changeAccountSelected)

        self.view?.showAccountHeader(viewModel)
    }

    func changeAccountSelected() {
        self.coordinator.goToAccountSelector(delegate: self)
    }

    func setupDestination() {
        guard let organization = operativeData?.organization else { return }
        let baseUrl = dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let alias = !organization.alias.isEmpty ? organization.alias : organization.identifier.replacingOccurrences(of: organizationCodePrefix, with: "")
        let viewModel = BizumDonationAmountDestinationViewModel(name: organization.name,
                                                                alias: alias,
                                                                identifier: organization.identifier,
                                                                baseUrl: baseUrl,
                                                                colorsByNameViewModel: ColorsByNameViewModel(colorsEngine.get(organization.name))
        )
        self.view?.showDestination(viewModel)
        let isDetailed = !(organization.alias.isEmpty || organization.name.isEmpty)
        self.updateDestinationVisibility(isDetailed)
    }

    func updateDestinationVisibility(_ isDetailed: Bool) {
        self.view?.updateDestinationVisibility(isDetailed)
    }
    
    func setupMultimediaView() {
        let multimediaViewModel = BizumMultimediaViewModel(multimediaData: self.operativeData?.multimediaData)
        self.multimediaViewModel = multimediaViewModel
        self.view?.showMultimediaView(multimediaViewModel)
    }

    func setupAmountView() {
        let viewModel = BizumSimpleAmountViewModel(operativeData?.bizumSendMoney)
        self.bizumSendMoney = operativeData?.bizumSendMoney ?? .makeEmpty
        self.view?.showSimpleSendMoney(viewModel)
        self.validatableFieldChanged()
    }

    func performSimpleSendMoneyUseCase() {
        guard let document = self.operativeData?.document,
              let organization = self.operativeData?.organization,
              let checkPayment = self.operativeData?.bizumCheckPaymentEntity,
              let amount = self.bizumSendMoney?.getAmount() else { return }
        let useCaseInput = BizumSimpleSendMoneyInputUseCase(
            checkPayment: checkPayment,
            document: document,
            concept: self.bizumSendMoney?.concept,
            amount: amount.getStringValue(),
            receiverUserId: organization.identifier,
            account: self.operativeData?.accountEntity
        )
        self.operativeData?.bizumSendMoney = self.bizumSendMoney
        let useCase: BizumValidateMoneyTransferUseCase = dependenciesResolver.resolve()
        self.view?.showLoading()
        Scenario(useCase: useCase, input: useCaseInput)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess(self.handleSendMoneySuccessfullResponse)
            .onError(self.handleSendMoneyErrorResponse)
    }

    func handleSendMoneySuccessfullResponse(_ response: BizumSimpleSendMoneyUseCaseOkOutput) {
        self.view?.dismissLoading { [weak self] in
            guard let self = self else { return }
            self.operativeData?.bizumValidateMoneyTransferEntity = response.bizumValidateMoneyTransferEntity
            let upddatedOrganization = BizumNGO(name: self.operativeData?.organization?.name ?? "",
                                                alias: response.bizumValidateMoneyTransferEntity.beneficiaryAlias ?? "",
                                                identifier: self.operativeData?.organization?.identifier ?? "")
            self.operativeData?.organization = upddatedOrganization
            self.operativeData?.multimediaData = self.multimediaViewModel?.multimediaData
            self.operativeData?.bizumSendMoney = self.bizumSendMoney
            self.container?.save(self.operativeData)
            self.container?.rebuildSteps()
            self.container?.stepFinished(presenter: self)
        }
    }

    func handleSendMoneyErrorResponse(_ error: UseCaseError<StringErrorOutput>) {
        self.view?.dismissLoading { [weak self] in
            guard let self = self else { return }
            self.view?.showErrorMessage(onAccept: { [weak self] in
                self?.operativeData?.multimediaData = self?.multimediaViewModel?.multimediaData
                self?.operativeData?.bizumSendMoney = self?.bizumSendMoney
                self?.container?.save(self?.operativeData)
                self?.container?.rebuildSteps()
                self?.container?.back(to: BizumDonationNGOSelectorPresenter.self)
            })
        }
    }
}

extension BizumDonationAmountPresenter: AutomaticScreenActionTrackable {
    var trackerPage: BizumAmountPage {
        let pageAssociated: TrackerPageAssociated
        pageAssociated = BizumDonationAmountPage()
        return BizumAmountPage(strategy: pageAssociated)

    }
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}

extension BizumDonationAmountPresenter: ColorsByNameProtocol {}
