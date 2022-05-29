//
//  OnboardingCoordinator.swift
//  Pods
//
//  Created by Boris Chirino Fernandez on 11/10/21.
//

import CoreFoundationLib
import UI

protocol OnboardingCoordinatorProtocol: AnyObject {
    func next()
    func previous()
    func cancel()
    func gotoScene(step: OnboardingStepIdentifier)
}

public final class OnboardingCoordinator: LauncherModuleCoordinator {
    private enum Constants {
        static let omittedStepsCount: Int = 2
        static let previousPositionDecrement: Int = 1
    }
    weak public var navigationController: UINavigationController?
    private let dependenciesEngine: DependenciesDefault
    private lazy var builder: OnboardingStepBuilder = {
        return OnboardingStepBuilder(dependenciesResolver: dependenciesEngine)
    }()
    private lazy var stepInteractor: StepInteractor = {
        return StepInteractor(steps: builder.build())
    }()
    private lazy var onboardingConfiguration: OnboardingConfigurationProtocol = {
        self.dependenciesEngine.resolve(for: OnboardingConfigurationProtocol.self)
    }()

    public init(dependenciesResolver: DependenciesResolver, navigationController: UINavigationController?) {
        self.navigationController = navigationController
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
    }
    
    public func start(withLauncher launcher: ModuleLauncher, handleBy delegate: ModuleLauncherDelegate) {
        let navigatorProvider = dependenciesEngine.resolve(for: NavigatorProvider.self)
        guard let presentationComponent = navigatorProvider.presenterProvider.dependencies else {
            return
        }
        let onboardingUserDataUseCase = presentationComponent.useCaseProvider.getOnboardingUseCase(dependencies: presentationComponent)
        launcher
            .does(useCase: onboardingUserDataUseCase, handledBy: delegate) { result in
                self.handleUserData(output: result)
                self.beginOnboarding()
        }
    }
}

private extension OnboardingCoordinator {
    func handleUserData(output: GetOnboardingUseCaseOkOutput) {
        guard let userPref = output.userPrefEntity else {
            return
        }
        let userData = OnboardingUserData(userId: userPref.userId,
                                          username: output.globalPosition.name,
                                          userAlias: userPref.getUserAlias() ?? "",
                                          currentLanguage: output.current,
                                          loginType: output.loginType,
                                          languages: output.list,
                                          items: output.items,
                                          globalPositionOnboardingSelectedValue: userPref.globalPositionOnboardingSelected().value(),
                                          photoThemeOnboardingSelectedValue: userPref.photoThemeOnboardingSelected(),
                                          smartThemeColorId: userPref.getPGColorMode().rawValue)
        self.onboardingConfiguration.userData = userData
    }
    
    func beginOnboarding() {
        if let customSteps = self.onboardingConfiguration.getCustomSteps(), !customSteps.isEmpty
        {
            for stepsInfo in customSteps {
                guard let step = stepsInfo?.step,
                      let identifier = stepsInfo?.identifier else {
                    continue
                }
                self.stepInteractor.insertStep(step, afterStepIdentifier: identifier)
            }
        }
        self.stepInteractor.resetCurrentPosition()
        guard let step = self.stepInteractor.next() else { return }
        guard let stepViewController = step.view as? UIViewController else { return }
        self.navigationController?.pushViewController(stepViewController, animated: true)
    }
}

extension OnboardingCoordinator: OnboardingCoordinatorProtocol {
    func gotoScene(step: OnboardingStepIdentifier) {
        if let onboardingStep = stepInteractor.getStepWithIdentifier(step),
           let viewController = onboardingStep.view as? UIViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func next() {
        guard let step = self.stepInteractor.next() else { return }
        guard let stepViewController = step.view as? UIViewController else { return }
        self.navigationController?.pushViewController(stepViewController, animated: true)
        if !self.stepInteractor.isLastStep() {
            self.addStepNavigationItems()
        }
    }
    
    func previous() {
        self.stepInteractor.popStep()
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancel() {}
}

private extension OnboardingCoordinator {
    func addStepNavigationItems() {
        let currentPosition = stepInteractor.getCurrentPosition()
        let total = stepInteractor.nonZeroIndexCount - Constants.omittedStepsCount
        guard total > 0 else { return }
        self.navigationController?.addStepIndicatorBar(currentPosition: currentPosition-Constants.previousPositionDecrement,
                                                       total: total)
    }
}

extension UINavigationController {
    func addStepIndicatorBar(currentPosition: Int, total: Int) {
        let textBar = UILabel()
        textBar.accessibilityIdentifier = "onboarding_label_steps"
        textBar.font = .santander(family: .text, type: .regular, size: 16)
        textBar.textColor = .lisboaGrayNew
        let placeHolders = [StringPlaceholder(.number, "\(currentPosition)"),
                            StringPlaceholder(.number, "\(total)")]
        let localizedText = localized("onboarding_label_steps", placeHolders)
        textBar.configureText(withLocalizedString: localizedText)
        textBar.sizeToFit()
        let barItem = UIBarButtonItem(customView: textBar)
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 18
        self.topViewController?.navigationItem.setLeftBarButtonItems([spacer, barItem], animated: false)
    }
}
