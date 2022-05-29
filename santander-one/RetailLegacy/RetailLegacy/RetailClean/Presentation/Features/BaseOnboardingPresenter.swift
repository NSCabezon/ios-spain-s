import UIKit
import UI

public protocol OnboardingClosableProtocol {}

public protocol OnboardingDelegate: AnyObject {
    func cancelOnboarding(cancelEnabled: Bool, completion: @escaping (() -> Void))
    var currentGlobalPosition: GlobalPositionOption? { get set }
    var isGlobalPositionChanged: Bool? { get set }
    func finishToDigitalProfile()
    func finishOnboarding()
}

protocol OnboardingPresenterProtocol: Presenter {
    func goBack()
    func goContinue()
    func scrolledToNewOption()
}
extension OnboardingPresenterProtocol {
    func scrolledToNewOption() {}
}

class BaseOnboardingPresenter<View, Navigator, Contract>: PrivatePresenter<View, OnboardingNavigatorProtocol, Contract>  where View: BaseViewController<Contract> {
    
    weak var delegate: OnboardingDelegate?
    var onboardingUserData: OnboardingUserData?
    var configuration: OnboardingConfigurationProtocol {
        self.dependencies.dependenciesEngine.resolve(for: OnboardingConfigurationProtocol.self)
    }
        
    override func viewWillAppear() {
        super.viewWillAppear()
        if configuration.allowOnboardingAbort {
            view.show(barButton: .title)
        } else {
            view.show(barButton: .none)
        }
        view.navigationController?.navigationBar.setClearBackground(flag: true)
        view.hideBackButton(true, animated: false)
    }
}

extension BaseOnboardingPresenter: Presenter {}

extension BaseOnboardingPresenter: CloseButtonAwarePresenterProtocol {
    func goToGlobalPosition() {
        guard let gpSelected = delegate?.currentGlobalPosition,
              let isGPChanged = delegate?.isGlobalPositionChanged,
              isGPChanged else { return }
        delegate?.currentGlobalPosition = nil
        delegate?.isGlobalPositionChanged = nil
        self.navigator.gpChanged(globalPositionOption: gpSelected)
    }

    func closeButtonTouched() {
        let onBoardingButtonsFont = UIFont.santander(family: .text, type: .regular, size: 14)
        ResumePopupView.presentPopup(title: localized(key: "onboarding_alert_title_completeActivation"),
                                     description: localized(key: "onboarding_alert_text_completeActivation"),
                                     confirmTitle: localized(key: "onboarding_alert_button_useApp"),
                                     cancelTitle: localized(key: "onboarding_alert_button_notPersonaliseApp"),
                                     font: onBoardingButtonsFont, hideCheckView: false) { [weak self] (confirmed, showNoMoreEnabled) in
            guard confirmed else { return }
            if let delegate = self?.delegate {
                delegate.cancelOnboarding(cancelEnabled: showNoMoreEnabled) {
                    self?.dismiss()
                }
            } else {
                self?.dismiss()
            }
        }
    }

    private func dismiss() {
        self.navigator.dismiss()
        self.goToGlobalPosition()
    }
}

extension BaseOnboardingPresenter: OnboardingStepPresenterConformable {
    var viewController: OnBoardingStepView? {
        self.view as? OnBoardingStepView
    }
}
