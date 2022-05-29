import UIKit
import CoreFoundationLib

protocol ActivateAndChangeSignPresenterProtocol: Presenter {
    var sections: [TableModelViewSection] { get }
    var buttonTitle: LocalizedStylableText { get }
    var title: LocalizedStylableText { get }
    func confirmButtonTouched()
}

class ActivateAndChangeSignPresenter: OperativeStepPresenter<ActivateAndChangeSignViewController, VoidNavigator, ActivateAndChangeSignPresenterProtocol> {
    lazy var newSignature: SecureTextFieldViewModel = {
        return SecureTextFieldViewModel(
            inputIdentifier: "",
            titleInfo: stringLoader.getString("signing_input_newKey"),
            keyboardType: .default, characterSet: CharacterSet.signature,
            dependencies: dependencies,
            accesibilityIds: SecureTextFielAccesibilityIds(
                title: AccessibilityActivateAndChange.signingInputNewKey,
                textField: AccessibilityActivateAndChange.changeSignViewInputSigningNew
            )
        )
    }()
    
    lazy var retypeSignature: SecureTextFieldViewModel = {
        return SecureTextFieldViewModel(
            inputIdentifier: "",
            titleInfo: stringLoader.getString("signing_input_repeatKey"),
            keyboardType: .default,
            characterSet: CharacterSet.signature,
            dependencies: dependencies,
            accesibilityIds: SecureTextFielAccesibilityIds(
                title: AccessibilityActivateAndChange.signingInputRepeatKey,
                textField: AccessibilityActivateAndChange.changeSignViewInputRepeatSigningNew
            )
        )
    }()
    
    var sections: [TableModelViewSection] {
        let sectionHeader = TableModelViewSection()
        let sectionContent = TableModelViewSection()
        let headerViewModel = GenericOperativeHeaderTitleAndDescriptionViewModel(
            title: stringLoader.getString("signing_titlle_about"),
            description: stringLoader.getString("signing_text_about"),
            accesibilityIds: GenericOperativeHeaderTitleAndDescriptionAccesibilityIds(
                title: AccessibilityActivateAndChange.signingTitlleAbout,
                description: AccessibilityActivateAndChange.signingTextAbout
            )
        )
        let headerCell = GenericHeaderViewModel(viewModel: headerViewModel, viewType: GenericOperativeHeaderTitleAndDescriptionView.self, dependencies: dependencies)
        sectionHeader.items = [headerCell]
        sectionContent.items = [newSignature, retypeSignature]
        return [sectionHeader, sectionContent]
    }
    
    var typeOperative: SettingOption?
    
    override func loadViewData() {
        super.loadViewData()
    }
    
    override var screenId: String? {
        if typeOperative == .activateSignature {
            return TrackerPagePrivate.PersonalAreaActivateMultichannelSign().page
        } else if typeOperative == .changeSignature {
            return TrackerPagePrivate.PersonalAreaUpdateMultichannelSign().page
        }
        return nil
    }
}

extension ActivateAndChangeSignPresenter: ActivateAndChangeSignPresenterProtocol {
    var title: LocalizedStylableText {
        if typeOperative == .activateSignature {
            return stringLoader.getString("toolbar_title_signingActivate")
        }
        return stringLoader.getString("toolbar_title_signingChange")
    }
    
    var buttonTitle: LocalizedStylableText {
        return stringLoader.getString("generic_button_save")
    }
    
    func confirmButtonTouched() {
        showOperativeLoading(titleToUse: nil, subtitleToUse: nil, source: nil)
        let input = ValidateSignatureActivationUseCaseInput(newSignature: newSignature.dataEntered, retypeSignature: retypeSignature.dataEntered, typeOperative: typeOperative)
        let usecase = useCaseProvider.validateSignatureActivationUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: useCaseHandler, errorHandler: genericErrorHandler, onSuccess: { [weak self] response in
            guard let presenter = self else { return }
            presenter.hideLoading(completion: {
                if let signatureAndToken = response.signatureToken, let newSignature = presenter.newSignature.dataEntered, let type = presenter.typeOperative {
                    let keyTitleAlert = (presenter.typeOperative == SettingOption.activateSignature) ? "signingActivate_alert_title_success" : "signing_alert_title_success"
                    let activateSignatureData = ActivateAndChangeSignatureOperativeData(newSignature: newSignature, successDialogTitle: presenter.stringLoader.getString(keyTitleAlert), successDialogMessage: presenter.stringLoader.getString("signing_alert_text_success"), successAcceptTitle: presenter.stringLoader.getString("generic_button_accept"), type: type)
                    presenter.container?.saveParameter(parameter: activateSignatureData)
                    presenter.container?.saveParameter(parameter: signatureAndToken)
                    presenter.container?.stepFinished(presenter: presenter)
                } else {
                    presenter.showError(keyDesc: nil)
                }
            })
            
        }, onError: { [weak self] error in
            guard let presenter = self else { return }
            let errorKey: String?
            if case let .localValidationErrorKey(key)? = error?.errorType {
                errorKey = key
            } else {
                errorKey = error?.getErrorDesc()
            }
            presenter.hideLoading(completion: {
                presenter.showError(keyTitle: "generic_alert_title_errorData", keyDesc: errorKey, phone: nil, completion: nil)
            })
        })
    }
}
