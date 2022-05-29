//
//  OnboardingViewModel.swift
//  Transfer
//
//  Created by Andres Aguirre Juarez on 27/1/22.
//

import UI
import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib
import Operative
import SANSpainLibrary
import ESCommons
import SANLibraryV3

public enum OnboardingState: State {
    case idle
    case showLoading(Bool)
    case showError(OneOperativeAlertErrorViewData?)
}

final class SKFirstStepOnboardingViewModel: DataBindable {
    private var anySubscriptions: Set<AnyCancellable> = []
    private let dependencies: SKFirstStepOnboardingDependenciesResolver
    private let stateSubject = CurrentValueSubject<OnboardingState, Never>(.idle)
    private let biometricsManager: LocalAuthenticationPermissionsManagerProtocol
    var state: AnyPublisher<OnboardingState, Never>
    let compilation: SpainCompilationProtocol
    
    init(dependencies: SKFirstStepOnboardingDependenciesResolver) {
        self.dependencies = dependencies
        state = stateSubject.eraseToAnyPublisher()
        self.biometricsManager = dependencies.external.resolve()
        self.compilation = dependencies.external.resolve()
    }

    func viewDidLoad() {}

    @objc func didTapVideo() {
        let videoOffer = PullOfferLocation(stringTag: "TRANSFER_TUTORIAL_VIDEO", hasBanner: false, pageForMetrics: nil)
        suscribeCandidate(location: videoOffer)
        stateSubject.send(.showLoading(true))
    }

    func didTapContinueButton() {
        if checkTokenPush() {
            stateSubject.send(.showLoading(true))
            checkClientStatus()
        } else {
            stateSubject.send(.showError(showPushBlockingError()))
        }
    }

    var dataBinding: DataBinding {
        return dependencies.resolve()
    }

    var operativeCoordinator: SKOperativeCoordinator {
        return dependencies.external.resolve()
    }
}

private extension SKFirstStepOnboardingViewModel {
    func checkTokenPush() -> Bool {
        let lookupQuery = KeychainQuery(compilation: compilation,
                                        accountPath: \.keychain.account.tokenPush)
        return (try? KeychainWrapper().fetch(query: lookupQuery) as? Data) != nil
    }
    
    var coordinator: SKFirstStepOnboardingCoordinator {
        return dependencies.resolve()
    }

    var getCandidateOfferUseCase: GetCandidateOfferUseCase {
        dependencies.external.resolve()
    }
    
    var transparentRegisterUseCase: SantanderKeyTransparentRegisterUseCase {
        dependencies.external.resolve()
    }
}

// MARK: - Subscriptions

private extension SKFirstStepOnboardingViewModel {
    func suscribeCandidate(location: PullOfferLocationRepresentable) {
        candidatePublisher(location: location)
            .subscribe(on: Schedulers.global)
            .receive(on: Schedulers.main)
            .map { Result.success($0) }
            .catch { error in
                Just(Result.failure(error))
            }
            .sink { [unowned self] result in
                switch result {
                case .success(let offer):
                    coordinator.goToPublicOffer(offer: offer)
                case .failure:
                    return
                }
                stateSubject.send(.showLoading(false))
            }
            .store(in: &anySubscriptions)
    }
    
    func checkClientStatus() {
        let statusClient: SantanderKeyStatusRepresentable? = dataBinding.get()
        if statusClient?.clientStatus == SantanderKeyClientStatusState.notRegistered {
            suscribeTransparentRegister()
        } else if statusClient?.clientStatus == SantanderKeyClientStatusState.resgisteredSafeDevice {
            coordinator.goToOperative()
        }
    }
    
    func suscribeTransparentRegister() {
        transparentRegisterPublisher()
            .subscribe(on: Schedulers.global)
            .receive(on: Schedulers.main)
            .sink { [unowned self] completion in
                if case .failure(let error) = completion {
                    handle(error: error)
                }
                self.stateSubject.send(.showLoading(false))
            } receiveValue: { [unowned self] result in
                if let sankeyId = result.sankeyId {
                    self.saveSankeyId(sankeyId)
                }
                let hasBiometry = self.biometricsManager.isTouchIdEnabled
                if hasBiometry {
                    self.coordinator.goToSecondStep()
                } else {
                    self.coordinator.goToBiometricsStep()
                }
            }.store(in: &anySubscriptions)
    }

    func handle(error: Error) {
        guard let errorType = error as? SantanderKeyError else {
            HapticTrigger.operativeError()
            stateSubject.send(.showError(nil))
            return
        }
        switch errorType.getAction() {
        case .goToPG, .goToOperative:
            stateSubject.send(.showError(showBlockingError(errorDescription: errorType.getLocalizedDescription())))
        case .stay:
            stateSubject.send(.showError(showStayError(errorDescription: errorType.getLocalizedDescription())))
        }
    }
    
    func showPushBlockingError() -> OneOperativeAlertErrorViewData {
        OneOperativeAlertErrorViewData(iconName: "oneIcnNotification",
                                       alertTitle: localized("sanKey_title_activateNotifications"),
                                       alertDescription: localized("sanKey_text_activationNotifications"),
                                       floatingButtonText: localized("otp_button_goGlobalPosition"),
                                       floatingButtonAction: { [unowned self] in
                                           coordinator.dismiss()
                                       },
                                       typeBottomSheet: .unowned,
                                       viewAccessibilityIdentifier: "")
    }

    func showBlockingError(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(
            iconName: "oneIcnWarning",
            alertDescription: errorDescription ?? "",
            floatingButtonText: localized("otp_button_goGlobalPosition"),
            floatingButtonAction: { [unowned self] in
                coordinator.dismiss()
            },
            typeBottomSheet: .unowned,
            viewAccessibilityIdentifier: ""
        )
    }

    func showStayError(errorDescription: String?) -> OneOperativeAlertErrorViewData {
        return OneOperativeAlertErrorViewData(
            iconName: "oneIcnWarning",
            alertDescription: errorDescription ?? "",
            floatingButtonText: localized("generic_button_accept"),
            typeBottomSheet: .all,
            viewAccessibilityIdentifier: ""
        )
    }

    func saveSankeyId(_ sanKeyId: String) {
        let sankeyIdQuery = KeychainQuery(service: compilation.service,
                                          account: compilation.keychainSantanderKey.sankeyId,
                                          accessGroup: compilation.sharedTokenAccessGroup,
                                          data: sanKeyId as NSCoding)
        do {
            try KeychainWrapper().save(query: sankeyIdQuery)
        } catch {
            return
        }
    }
}

// MARK: - Publishers

private extension SKFirstStepOnboardingViewModel {
    func candidatePublisher(location: PullOfferLocationRepresentable) -> AnyPublisher<OfferRepresentable, Error> {
        return getCandidateOfferUseCase.fetchCandidateOfferPublisher(location: location)
    }
    
    func transparentRegisterPublisher() -> AnyPublisher<SantanderKeyAutomaticRegisterResultRepresentable, Error> {
        return transparentRegisterUseCase.completeTransparentRegister()
    }
}
