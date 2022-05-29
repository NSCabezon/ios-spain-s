//
//  StepBuilder.swift
//  RetailLegacy
//
//  Created by Boris Chirino Fernandez on 14/10/21.
//

import CoreFoundationLib

final class OnboardingStepBuilder {
    private var steps: [OnBoardingStepConformable] = []
    private let dependenciesResolver: DependenciesResolver
    private let configuration: OnboardingConfigurationProtocol
    private lazy var navigatorProvider: NavigatorProvider = {
        dependenciesResolver.resolve(for: NavigatorProvider.self)
    }()
    private lazy var stepFactory: StepFactory = {
        StepFactory(dependenciesResolver: dependenciesResolver)
    }()
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
        self.configuration = self.dependenciesResolver.resolve(for: OnboardingConfigurationProtocol.self)
    }
    
    func build() -> [OnBoardingStepConformable] {
        configuration.steps.forEach { scene in
            switch scene {
            case .welcome:
                addWelcomeStep()
                addAliasStep()
            case .language:
                addLanguageStep()
            case .options:
                addOptionsStep()
            case .globalPosition:
                addPGStep()
            case .photoTheme:
                addThemeStep()
            case .final:
                addFinal()
            default:
                break
            }
        }
        return self.steps
    }
    
    func addWelcomeStep() {
        let presenter = navigatorProvider.presenterProvider.onboardingWelcomePresenter
        let step = stepFactory.createWelcomeStep(presenter: presenter)
        self.steps.append(step)
    }
    
    func addLanguageStep() {
        let presenter = navigatorProvider.presenterProvider.onboardingLanguagesPresenter
        let step = stepFactory.createLanguageStep(presenter: presenter)
        self.steps.append(step)
    }
    
    func addOptionsStep() {
        let presenter = navigatorProvider.presenterProvider.onboardingOptionsPresenter
        let step = stepFactory.createOptionsStep(presenter: presenter)
        self.steps.append(step)
    }
    
    func addPGStep() {
        let presenter = navigatorProvider.presenterProvider.onboardingGlobalPositionPagerPresenter
        let step = stepFactory.createPGStep(presenter: presenter)
        self.steps.append(step)
    }
    
    func addThemeStep() {
        let presenter = navigatorProvider.presenterProvider.onboardingPhotoThemePagerPresenter
        let step = stepFactory.createThemeStep(presenter: presenter)
        self.steps.append(step)
    }
    
    func addAliasStep() {
        let presenter = navigatorProvider.presenterProvider.onboardingChangeAliasPresenter
        let step = stepFactory.createAliasStep(presenter: presenter)
        self.steps.append(step)
    }
    
    func addFinal() {
        let finalPresenter = navigatorProvider.presenterProvider.onboardingFinalPresenter
        let finalStep = stepFactory.createFinalStep(presenter: finalPresenter)
        self.steps.append(finalStep)
    }
}
