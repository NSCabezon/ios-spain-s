import Foundation
import CoreFoundationLib
import Operative
import SANLegacyLibrary
import UI

struct FieldErrorViewModel {
    let identifier: String
    let error: String
}

struct FieldViewModel {
    let entity: TaxCollectionFieldEntity
    var description: String {
        return self.entity.fieldDescription
    }
    var length: Int {
        return Int(self.entity.fieldLength) ?? 0
    }
    
    var identifier: String {
        return entity.fieldDescription
    }
}

struct EmitterSelectedViewModel {
    let entity: EmitterEntity
    var name: String {
        return self.entity.name
    }
    var code: String {
        return self.entity.code
    }
    let url: String?
    
    var urlImage: String {
        return String(format: "%@RWD/emisoras/iconos/%@.png", self.url ?? "", self.entity.code)
    }
}

enum FieldViewModelType {
    case field(FieldViewModel)
    case date(String)
    case amount
}

protocol BillEmittersManualPaymentPresenterProtocol: OperativeStepPresenterProtocol, ValidatableFormPresenterProtocol, MenuTextWrapperProtocol {
    var view: BillEmittersManualPaymentViewProtocol? { get set }
    func viewDidLoad()
    func didSelectChangeAccount()
    func didSelectContinue(withValues values: [BillEmittersManualPaymentFieldRetrievableValue])
    func didTapFaqs()
    func didTapClose()
    func trackFaqEvent(_ question: String, url: URL?)
}

typealias TaxColletionFieldWithValue = (key: TaxCollectionFieldEntity, value: String)

class BillEmittersManualPaymentPresenter {
    weak var view: BillEmittersManualPaymentViewProtocol?
    let dependenciesResolver: DependenciesResolver
    var number: Int = 0
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var operativeData: BillEmittersPaymentOperativeData {
        guard let container = self.container else { fatalError() }
        return container.get()
    }
    var fields: [ValidatableField] = []

    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    private var getValidateManualPayment: ValidateFieldsManualPaymentUseCase {
        return dependenciesResolver.resolve(for: ValidateFieldsManualPaymentUseCase.self)
    }
}

extension BillEmittersManualPaymentPresenter: BillEmittersManualPaymentPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        guard let formats = self.operativeData.formats, let selectedAccount = self.operativeData.selectedAccount, let entity: EmitterEntity = self.operativeData.selectedEmitter else { return }
        let date = self.dependenciesResolver.resolve(for: TimeManager.self).toString(date: formats.systemDate, outputFormat: .d_MMM_yyyy) ?? ""
        let fieldViewModels = formats.fields.map {
            FieldViewModelType.field(FieldViewModel(entity: $0))
        }
        let fields: [FieldViewModelType] = fieldViewModels + [.date(date), .amount]
        self.view?.showEmitterView(viewModel: EmitterSelectedViewModel(entity: entity, url: dependenciesResolver.resolve(for: BaseURLProvider.self).baseURL))
        self.view?.showFields(fields)
        self.view?.showEditAccount(
            alias: selectedAccount.alias ?? "",
            amount: selectedAccount.availableAmount?.getStringValue() ?? ""
        )
        self.validatableFieldChanged()
    }
    
    func didSelectChangeAccount() {
        self.container?.back(
            to: BillEmittersPaymentAccountSelectorPresenter.self,
            creatingAt: 0,
            step: BillEmittersPaymentAccountSelectorStep(dependenciesResolver: self.dependenciesResolver)
        )
    }
    
    func didSelectContinue(withValues values: [BillEmittersManualPaymentFieldRetrievableValue]) {
        var amount: String = ""
        var fields: [TaxColletionFieldWithValue] = []
        values.forEach { value in
            switch value.value {
            case .any(viewModel: let viewModel, value: let value):
                guard let entity = viewModel?.entity else { return }
                fields.append((entity, value))
            case .amount(value: let value):
                amount = value
            }
        }
        
        UseCaseWrapper(with: self.getValidateManualPayment.setRequestValues(requestValues: GetValidateFieldsManualPaymentUseCaseInput(amount: amount, fields: fields)), useCaseHandler: dependenciesResolver.resolve(for: UseCaseHandler.self),
                       onSuccess: {
                        self.operativeData.fields = fields
                        self.operativeData.amount = AmountEntity(value: Decimal(string: amount) ?? 0.0)
                        self.container?.save(self.operativeData)
                        self.container?.stepFinished(presenter: self)
        },
                       onError: { [weak self] errorResult in
                        guard let self = self else { return }
                        guard case let .error(err) = errorResult else { return }
                        let filedErrors = err?.errors.map({ (identifier, error) in
                            return FieldErrorViewModel(identifier: identifier, error: error)
                        }) ?? []
                        self.view?.updateContinueAction(false)
                        self.view?.showErrors(filedErrors)
            }
        )
    }
    
    func validatableFieldChanged() {
        self.view?.updateContinueAction(isValidForm)
    }
    
    func didTapFaqs() {
        trackEvent(.faq, parameters: [:])
        let faqModel = operativeData.faqs?.map {
            return FaqsItemViewModel(id: $0.id, title: $0.question, description: $0.answer)
        } ?? []
        trackerManager.trackScreen(screenId: BillEmittersPaymentFaqPage().page, extraParameters: [:])
        self.view?.showFaqs(faqModel)
    }
    
    func didTapClose() {
        container?.close()
    }
    
    func trackFaqEvent(_ question: String, url: URL?) {
        var dic: [String: String] = ["faq_question": question]
        if let link = url?.absoluteString {
            dic["faq_link"] = link
        }
        NotificationCenter.default.post(name: NSNotification.Name("billsFaqsAnalytics"), object: nil, userInfo: ["parameters": dic])
    }
}

extension BillEmittersManualPaymentPresenter: AutomaticScreenActionTrackable {
    
    var trackerPage: BillEmittersManualPaymentPage {
        BillEmittersManualPaymentPage()
    }
    
    var trackerManager: TrackerManager {
        dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
