//
//  OnboardingFinalPresenter.swift
//  RetailClean
//
//  Created by alvola on 03/10/2019.
//  Copyright © 2019 Ciber. All rights reserved.
//
import UIKit
import CoreFoundationLib

final class OnboardingFinalPresenter: BaseOnboardingPresenter<OnboardingFinalViewController, OnboardingNavigator, OnboardingFinalPresenterProtocol> {
    private let localAuthentication: LocalAuthenticationPermissionsManagerProtocol
    private let digitalProfile: Bool

    init(dependencies: PresentationComponent, navigator: OnboardingNavigatorProtocol, sessionManager: CoreSessionManager, localAuthentication: LocalAuthenticationPermissionsManagerProtocol) {
        self.localAuthentication = localAuthentication
        self.digitalProfile = dependencies.localAppConfig.digitalProfile
        super.init(dependencies: dependencies, sessionManager: sessionManager, navigator: navigator)
    }
    
    override func loadViewData() {
        super.loadViewData()
    }
    
    // MARK: - TrackerScreenProtocol
    
    override var screenId: String? {
        return OnboardingFinal().page
    }
    
    private var notificationPermissionsManager: PushNotificationPermissionsManagerProtocol? {
        self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: PushNotificationPermissionsManagerProtocol.self)
    }
    
    private lazy var otpPushManager: OtpPushManagerProtocol? = {
        self.dependencies.useCaseProvider.dependenciesResolver.resolve(forOptionalType: APPNotificationManagerBridgeProtocol.self)?.getOtpPushManager()
    }()
}

private extension OnboardingFinalPresenter {
    func setDigitalProfile() {
        self.otpPushManager?.updateToken(completion: { [weak self] _, _ in
            guard let self = self else { return }
            let input = GetDigitalProfilePercentageUseCaseInput(pushNotificationsManager: self.notificationPermissionsManager,
                                                                locationManager: self.dependencies.locationManager,
                                                                localAuthentication: self.localAuthentication)
            let usecase = self.dependencies.useCaseProvider.getDigitalProfilePercentageUseCase(input: input)
            UseCaseWrapper(with: usecase,
                           useCaseHandler: self.dependencies.useCaseHandler,
                           errorHandler: self.genericErrorHandler,
                           onSuccess: { [weak self] (result) in
                            self?.view.setProgress(result.percentage / 100)
                           })
        })
    }
}

// MARK: - OnboardingFinalPresenterProtocol methods
extension OnboardingFinalPresenter: OnboardingFinalPresenterProtocol {
    func loadDigitalProfile() {
        if self.digitalProfile {
            self.setDigitalProfile()
        }
    }
    
    func configureDigitalProfile() {
        self.view.configureViews(self.digitalProfile)
    }
    
    func continueWithSettings() {
        CATransaction.begin()
        CATransaction.setCompletionBlock({ [weak self] in
            self?.delegate?.finishToDigitalProfile()
        })
        self.goContinue()
    }
    
    func goBack() {
        navigator.goBack()
    }
    
    func goContinue() {
        self.navigator.dismiss()
        self.delegate?.finishOnboarding()
        CATransaction.commit()
        self.goToGlobalPosition()
        CATransaction.flush()
    }
}
