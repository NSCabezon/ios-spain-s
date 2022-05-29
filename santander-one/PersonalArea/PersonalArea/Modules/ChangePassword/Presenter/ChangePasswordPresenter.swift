import CoreFoundationLib
import Operative

protocol ChangePasswordPresenterProtocol: ValidatableFormPresenterProtocol, OperativeStepPresenterProtocol {
    var view: ChangePasswordViewProtocol? { get set }
    var isForcedFromLogin: Bool { get set }
    func viewDidLoad()
    func viewWillAppear()
    func didSelectContinue()
    func getCustomTextValidatorProtocol() -> TextFieldValidatorProtocol?
}

final class ChangePasswordPresenter {
    var view: ChangePasswordViewProtocol?
    var customValidatorTextProtocol: TextFieldValidatorProtocol? {
        return self.dependencies.resolve(firstOptionalTypeOf: TextFieldValidatorProtocol.self)
    }
    var number: Int = 0
    var isBackButtonEnabled: Bool = true
    var isCancelButtonEnabled: Bool = false
    var isForcedFromLogin: Bool = false
    var container: OperativeContainerProtocol?
    var fields: [ValidatableField] = []
    private let dependencies: DependenciesResolver
    var changePasswordConfiguration: ChangePasswordConfiguration {
        return self.dependencies.resolve(firstTypeOf: ChangePasswordConfiguration.self)
    }
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependencies = dependenciesResolver
    }
}

extension ChangePasswordPresenter: ChangePasswordPresenterProtocol {
    func viewDidLoad() {
        self.trackScreen()
        self.view?.showPasswordConfiguration(self.changePasswordConfiguration)
        self.addComponents()
    }
    
    func viewWillAppear() {
        self.container?.restoreProgressBar()
        if isForcedFromLogin {
            self.view?.setForcedAppareance()
        }
    }
    
    func didSelectContinue() {
        self.view?.showLoading()
        self.prevalidate()
    }
    
    func validatableFieldChanged() {
        self.view?.updateContinueAction(isValidForm)
    }
    
    var isValidForm: Bool {
        guard let view = self.view,
              !view.textFields.isEmpty
              else { return false }
        let text = view.textFields.map { $0.text }.dropFirst()
        guard text.count == text.compactMap({ $0 }).count else { return false }
        let stringValues = text.compactMap { $0 }
        guard (stringValues.map { $0.count >= self.changePasswordConfiguration.minLength }.allSatisfy { $0 }) else { return false }
        guard let currentPasswordTextfield = view.textFields.map { $0.text }.first,
              let currentPasswordTextfieldLength = currentPasswordTextfield?.count else { return false }
        return currentPasswordTextfieldLength >= 2 && currentPasswordTextfieldLength <= self.changePasswordConfiguration.maxLength
    }
    
    func getCustomTextValidatorProtocol() -> TextFieldValidatorProtocol? {
        return customValidatorTextProtocol
    }
}

private extension ChangePasswordPresenter {
    func prevalidate() {
        guard let textFields = self.view?.textFields,
              let oldPassword = textFields[0].text,
              let newPassword = textFields[1].text,
              let confirmPassword = textFields[2].text
        else { return }
        let input = ValidateChangePasswordUseCaseInput(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword)
        Scenario(useCase: self.dependencies.resolve(firstTypeOf: PrevalidateChangePasswordUseCaseProtocol.self), input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess({ [weak self] in
                self?.validate()
            })
            .onError { [weak self] error in
                self?.handleError(error)
            }
    }
    
    func validate() {
        guard let textFields = self.view?.textFields,
              let oldPassword = textFields[0].text,
              let newPassword = textFields[1].text,
              let confirmPassword = textFields[2].text
        else { return }
        let input = ValidateChangePasswordUseCaseInput(oldPassword: oldPassword, newPassword: newPassword, confirmPassword: confirmPassword)
        Scenario(useCase: self.dependencies.resolve(firstTypeOf: ValidateChangePasswordUseCaseProtocol.self), input: input)
            .execute(on: self.dependencies.resolve())
            .onSuccess({ [weak self] in
                self?.view?.dismissLoading(completion: { [weak self] in
                    guard let self = self else { return }
                    self.trackEvent(.okResponse, parameters: [:])
                    self.container?.save(ChangePasswordOperative.FinishingOption.security)
                    ForcedPasswordUpdateProxy.shared.notifyForcedPasswordUpdated()
                    self.container?.stepFinished(presenter: self)
                })
            })
            .onError { [weak self] error in
                self?.handleError(error)
            }
    }
    
    func handleError(_ error: UseCaseError<ValidateChangePasswordUseCaseErrorOutput>) {
        self.view?.dismissLoading(completion: { [weak self] in
            self?.trackEvent(.error, parameters: [.codError: error.getErrorDesc() ?? ""])
            switch error {
            case .error(let error):
                guard let error = error, let self = self else { return }
                self.handleCustomError(with: error)
            case .generic, .intern, .networkUnavailable, .unauthorized:
                guard let self = self else { return }
                self.container?.showGenericError()
            }
        })
    }
    
    func handleCustomError(with error: ValidateChangePasswordUseCaseErrorOutput) {
        switch error.errorPass {
        case .different:
            self.view?.showErrorAlertView(localized("keyChange_alert_text_notMatch"), positions: [1, 2])
        case .other:
            var errorMessage: LocalizedStylableText = .empty
            if !error.localizedDescription.isEmpty {
                errorMessage = LocalizedStylableText(text: error.localizedDescription, styles: nil)
            } else {
                errorMessage = localized("keyChange_alert_changeError")
            }
            self.view?.showErrorAlertView(errorMessage, positions: [1, 2])
        case .charactersValidated:
            self.view?.showErrorAlertView(localized("keyChange_popupError_digitsKey"), positions: [1, 2])
        case .errorValidationPassword:
            self.view?.showErrorUnderTexField(localized("keyChange_popupError_currentKey"), [0], identifier: "keyChange_popupError_currentKey")
        case .differentThanNCharacters, .empty, .notnumeric:
            break
        }
    }
    
    func addComponents() {
        self.view?.addLabel(isForcedFromLogin ? localized("keyChange_text_forSecurity") : self.changePasswordConfiguration.message)
        let textfields = [
            ChangePasswordTextFieldViewModel(identifier: "keyChange_input_currentKey", placeHolder: localized("keyChange_input_currentKey")),
            ChangePasswordTextFieldViewModel(identifier: "keyChange_input_newKey", placeHolder: localized("keyChange_input_newKey")),
            ChangePasswordTextFieldViewModel(identifier: "keyChange_input_repeatKey", placeHolder: localized("keyChange_input_repeatKey"))
        ]
        self.view?.addTextField(viewModels: textfields)
    }
}

extension ChangePasswordPresenter: AutomaticScreenActionTrackable {
    var trackerPage: PersonalAreaUpdateAccessKey {
        return PersonalAreaUpdateAccessKey()
    }
    var trackerManager: TrackerManager {
        return dependencies.resolve(for: TrackerManager.self)
    }
}
