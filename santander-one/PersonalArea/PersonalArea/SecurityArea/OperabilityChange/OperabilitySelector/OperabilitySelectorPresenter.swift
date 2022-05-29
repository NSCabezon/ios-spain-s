//
//  OperabilitySelectorPresenter.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 18/05/2020.
//

import Operative
import CoreFoundationLib
import UI

protocol OperabilitySelectorPresenterProtocol: OperativeStepPresenterProtocol {
    var view: OperabilitySelectorViewProtocol? { get set }
    func viewDidLoad()
    func didSelectContinue()
    func didSelectIndicator(_ indicator: OperabilityInd)
}

class OperabilitySelectorPresenter {
    
    let dependenciesResolver: DependenciesResolver
    weak var view: OperabilitySelectorViewProtocol?
    var container: OperativeContainerProtocol?
    var isBackButtonEnabled: Bool = false
    var isCancelButtonEnabled: Bool = false
    var number: Int = 0
    
    lazy var operativeData: OperabilityChangeOperativeData = {
        guard let container = self.container else { fatalError() }
        return container.get()
    }()
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension OperabilitySelectorPresenter: OperabilitySelectorPresenterProtocol {
    
    func viewDidLoad() {
        view?.setOperabilityIndicator(operativeData.operabilityInd)
        view?.setContinueButtonIsEnabled(false)
    }
    
    func didSelectIndicator(_ indicator: OperabilityInd) {
        guard !operativeData.isUnderage else {
            guard indicator == .operative else { return }
            view?.showUnderageDialog()
            return
        }
        
        operativeData.newOperabilityInd = indicator
        container?.save(self.operativeData)
        view?.setContinueButtonIsEnabled(operativeData.operabilityInd != operativeData.newOperabilityInd)
    }
    
    func didSelectContinue() {
        guard !operativeData.isUserWithoutCMC else {
            showCMCError()
            return
        }
        guard !operativeData.isSignatureBlocked else {
            showRevokedError()
            return
        }
        self.view?.showLoading()
        if let newIndicator = operativeData.newOperabilityInd {
            trackEvent(.next, parameters: [.operativityType: newIndicator.trackName])
        }
        UseCaseWrapper(
            with: self.dependenciesResolver.resolve(for: ValidateChangeOperabilityUseCase.self),
            useCaseHandler: self.dependenciesResolver.resolve(for: UseCaseHandler.self),
            onSuccess: { [weak self] result in
                guard let self = self else { return }
                self.view?.dismissLoading {
                    self.container?.save(result.signatureWithToken)
                    self.container?.stepFinished(presenter: self)
                }
            },
            onError: { [weak self] errorResult in
                self?.view?.dismissLoading {
                    guard let self = self else { return }
                    self.view?.showDialog(
                        withDependenciesResolver: self.dependenciesResolver,
                        description: errorResult.getErrorDesc()
                    )
                }
            }
        )
    }
    
    func showCMCError() {
        view?.showCMCDialog()
    }
    
    func showRevokedError() {
        guard let container = self.container else { return }
        let operativesConfig: OperativeConfig = container.get()
        let phoneNumber = operativesConfig.signatureSupportPhone
        guard let isEmptyPhone = phoneNumber?.isEmpty else { return }
        let errorDescKey: String
        if isEmptyPhone {
            errorDescKey = "signing_text_popup_blocked_withoutNumber"
        } else {
            errorDescKey = "signing_text_popup_blocked"
        }
        let localizedString: LocalizedStylableText = localized(errorDescKey)
        let acceptButton: LocalizedStylableText = localized("signing_button_call", [StringPlaceholder(.phone, phoneNumber ?? "")])
        self.view?.showDialog(
            title: localized("signing_title_popup_blocked"),
            items: [
                .styledConfiguredText(localizedString, configuration: LocalizedStylableTextConfiguration(font: nil, textStyles: nil, alignment: .center, lineHeightMultiple: nil, lineBreakMode: nil))
            ],
            image: "icnAlertError",
            action: Dialog.Action(title: acceptButton.text, action: {
                self.container?.goToFirstOperativeStep()
            }),
            isCloseOptionAvailable: true
        )
    }
}

extension OperabilitySelectorPresenter: AutomaticScreenActionTrackable {
    var trackerPage: OperabilitySelectorPage {
        return OperabilitySelectorPage()
    }
    
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
