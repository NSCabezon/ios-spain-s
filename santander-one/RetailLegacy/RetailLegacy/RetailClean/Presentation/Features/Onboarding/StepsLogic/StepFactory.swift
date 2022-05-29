//
//  StepFactory.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 18/10/21.
//
import CoreFoundationLib

final class StepFactory {
    let dependenciesEngine: DependenciesDefault

    required init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesEngine = DependenciesDefault(father: dependenciesResolver)
    }
    
    // MARK: concrete step creation
    func createWelcomeStep(presenter: OnboardingStepPresenterConformable) -> OnBoardingStepConformable {
        let step = OnboardingWelcomeStep()
        var mutablePresenter = presenter
        self.assemblePresenter(&mutablePresenter)
        step.view = mutablePresenter.viewController
        return step
    }
    
    func createAliasStep(presenter: OnboardingStepPresenterConformable) -> OnBoardingStepConformable {
        let step = OnboardingAliasStep()
        var mutablePresenter = presenter
        self.assemblePresenter(&mutablePresenter)
        step.view = mutablePresenter.viewController
        return step
    }
    
    func createLanguageStep(presenter: OnboardingStepPresenterConformable) -> OnBoardingStepConformable {
        let step = OnboardingLanguageStep()
        var mutablePresenter = presenter
        self.assemblePresenter(&mutablePresenter)
        step.view = mutablePresenter.viewController
        return step
    }
    
    func createOptionsStep(presenter: OnboardingStepPresenterConformable) -> OnBoardingStepConformable {
        let step = OnboardingOptionsStep()
        var mutablePresenter = presenter
        self.assemblePresenter(&mutablePresenter)
        step.view = mutablePresenter.viewController
        return step
    }
    
    func createPGStep(presenter: OnboardingStepPresenterConformable) -> OnBoardingStepConformable {
        let step = OnboardingGobalPositionStep()
        var mutablePresenter = presenter
        self.assemblePresenter(&mutablePresenter)
        step.view = mutablePresenter.viewController
        return step
    }
    
    func createThemeStep(presenter: OnboardingStepPresenterConformable) -> OnBoardingStepConformable {
        let step = OnboardingPhotoThemeStep()
        var mutablePresenter = presenter
        self.assemblePresenter(&mutablePresenter)
        step.view = mutablePresenter.viewController
        return step
    }
    
    func createFinalStep(presenter: OnboardingStepPresenterConformable) -> OnBoardingStepConformable {
        let step = OnboardingFinalStep()
        var mutablePresenter = presenter
        self.assemblePresenter(&mutablePresenter)
        step.view = mutablePresenter.viewController
        return step
    }
    
    // MARK: abstract step creation
    static func createStep<StepType>(step: StepType.Type, presenter: OnboardingStepPresenterConformable, configuration: OnboardingConfiguration) -> OnBoardingStepConformable? where StepType: OnBoardingStepConformable {
        presenter.delegate = configuration.onboardingDelegate
        presenter.onboardingUserData = configuration.userData
        let onboardingStep: OnBoardingStepConformable = step.init()
        onboardingStep.view = presenter.viewController
        return onboardingStep
    }
}

private extension StepFactory {
    func assemblePresenter(_ presenter: inout OnboardingStepPresenterConformable) {
        let configuration = dependenciesEngine.resolve(for: OnboardingConfigurationProtocol.self)
        presenter.delegate = configuration.onboardingDelegate
        presenter.onboardingUserData = configuration.userData
    }
}
