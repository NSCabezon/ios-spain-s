import CoreFoundationLib
import Operative

protocol NewFavouriteAliasPresenterProtocol: ValidatableFormPresenterProtocol, OperativeStepPresenterProtocol {
    var view: NewFavouriteAliasViewProtocol? { get set }
    func viewDidLoad()
    func didSelectContinue()
}

final class NewFavouriteAliasPresenter {
    var view: NewFavouriteAliasViewProtocol?
    var number: Int = 1
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = false
    var container: OperativeContainerProtocol?
    var fields: [ValidatableField] = []
    private let dependencies: DependenciesResolver
    lazy var operativeData: NewFavouriteOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    private var controlDigitDelegate: IbanCccTransferControlDigitDelegate? {
        dependencies.resolve(forOptionalType: IbanCccTransferControlDigitDelegate.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
    }
}

private extension NewFavouriteAliasPresenter {
    func addComponents() {
        let textfields = [
            NewFavouriteTextFieldViewModel(identifier: AccessibilityUsualTransfer.aliasLabel.rawValue, placeHolder: localized("pt_cross_hint_saveFavoriteName"), maxLength: 50),
            NewFavouriteTextFieldViewModel(identifier: AccessibilityUsualTransfer.holderLabel.rawValue, placeHolder: localized("sendMoney_label_recipients"), maxLength: 50)
        ]
        self.view?.addTextField(viewModels: textfields)
        guard let country = self.operativeData.country else { return }
        let bankingUtils: BankingUtilsProtocol = self.dependencies.resolve()
        bankingUtils.setCountryCode(country.code)
        self.view?.setBankingUtil(bankingUtils, controlDigitDelegate: self.controlDigitDelegate)
    }
    
    func validate() {
        let textFieldValues = self.fields.compactMap { $0.fieldValue }
        guard textFieldValues.count == 3,
              let iban = self.view?.ibanLisboaTextField
        else {
            self.view?.dismissLoading()
            return
        }
        let alias = textFieldValues[0]
        let beneficiaryName = textFieldValues[1]
        let input = PreValidateNewFavouriteUseCaseInput(iban: iban, alias: alias)
        Scenario(useCase: self.dependencies.resolve(firstTypeOf: PreValidateNewFavouriteUseCaseProtocol.self), input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess({ [weak self] result in
                self?.view?.dismissLoading(completion: { [weak self] in
                    guard let self = self else { return }
                    self.operativeData.alias = result.alias
                    self.operativeData.iban = result.iban
                    self.operativeData.beneficiaryName = beneficiaryName
                    self.container?.save(self.operativeData)
                    self.container?.stepFinished(presenter: self)
                })
            })
            .onError { [weak self] error in
                self?.view?.dismissLoading(completion: {
                    self?.handleError(error)
                    self?.view?.updateContinueAction(false)
                })
            }
    }
    
    func handleError(_ error: UseCaseError<PreValidateNewFavouriteUseCaseErrorOutput>) {
        switch error {
        case .error(let error):
            guard let errorInfo = error?.errorInfo else { return }
            self.errorInfo(errorInfo)
        case .generic, .intern, .networkUnavailable, .unauthorized:
            self.container?.showGenericError()
        }
    }
    
    func errorInfo(_ error: ErrorDescriptionType) {
        switch error {
        case .key(let key):
            self.view?.showOldErrorData(localized(key))
        case .keyWithPlaceHolder:
            break
        }
    }
}

extension NewFavouriteAliasPresenter: NewFavouriteAliasPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.addComponents()
    }
    
    func didSelectContinue() {
        self.view?.showLoading()
        self.validate()
    }
    
    func validatableFieldChanged() {
        self.view?.updateContinueAction(isValidForm)
    }
}

extension NewFavouriteAliasPresenter: AutomaticScreenTrackable {
    var trackerPage: NewFavouriteAliasPage {
        return NewFavouriteAliasPage()
    }
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
}
