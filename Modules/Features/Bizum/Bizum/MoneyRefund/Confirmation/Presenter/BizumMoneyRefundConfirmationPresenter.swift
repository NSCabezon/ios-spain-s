import Foundation
import CoreFoundationLib
import Operative

protocol BizumRefundMoneyConfirmationPresenterProtocol: BizumConfirmationWithCommentPresenterProtocol {
    var view: BizumRefundMoneyConfirmationViewProtocol? { get set }
    func viewDidLoad()
    func didTapClose()
    func getContact()
}

class BizumRefundMoneyConfirmationPresenter {
    
    weak var view: BizumRefundMoneyConfirmationViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    private lazy var operativeData: BizumRefundMoneyOperativeData? = {
        return self.container?.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func viewDidLoad() {
        self.trackScreen()
        self.loadData()
        self.view?.setContinueTitle(localized("generic_button_continue"))
    }
}

extension BizumRefundMoneyConfirmationPresenter: BizumRefundMoneyConfirmationPresenterProtocol {
    
    func didSelectContinue(comment: String?) {
        let useCase = self.dependenciesResolver.resolve(for: SignPosSendMoneyUseCase.self)
        Scenario(useCase: useCase)
            .execute(on: self.dependenciesResolver.resolve())
            .onSuccess { [weak self] result in
                self?.operativeData?.comment = comment
                self?.container?.save(result.signatureWithTokenEntity)
            }
            .finally { [weak self] in
                guard let self = self else { return }
                self.container?.stepFinished(presenter: self)
            }
    }
    
    func getContact() {
        guard let contact = self.operativeData?.bizumContacts.first else { return }
        let amount = self.operativeData?.totalAmount
        let viewModel = ConfirmationContactDetailViewModel(
            identifier: contact.identifier,
            name: contact.name,
            alias: contact.alias,
            initials: (contact.name ?? contact.alias ?? "").nameInitials,
            phone: contact.phone,
            amount: amount,
            validateSendAction: contact.validateSendAction?.capitalized,
            colorModel: self.getColorByName(contact.identifier))
        self.view?.setContact(viewModel)
    }
    
    func didTapClose() {
        self.container?.close()
    }
}

private extension BizumRefundMoneyConfirmationPresenter {
    var signPosUseCase: SignPosSendMoneyUseCase {
        return dependenciesResolver.resolve(for: SignPosSendMoneyUseCase.self)
    }
    
    func loadData() {
        guard let data = self.operativeData else { return }
        let builder = BizumRefundMoneyConfirmationBuilder(data: data, dependenciesResolver: self.dependenciesResolver)
        builder.addAmountAndConcept()
        builder.addContacts()
        builder.addDate()
        builder.addOriginAccount()
        builder.addTransferType()
        builder.addTotal()
        self.view?.add(builder.build())
    }
    
    func getColorByName(_ identifier: String) -> ColorsByNameViewModel {
        let colorsEngine: ColorsByNameEngine = self.dependenciesResolver.resolve()
        let colorType = colorsEngine.get(identifier)
        return ColorsByNameViewModel(colorType)
    }
}

extension BizumRefundMoneyConfirmationPresenter: AutomaticScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
    
    var trackerPage: BizumRefundMoneyConfirmationPage {
        return BizumRefundMoneyConfirmationPage()
    }
}
