//
//  SecurityAreaSections.swift
//  Santander
//
//  Created by Rubén Márquez Fernández on 26/4/21.
//

import CoreFoundationLib
import PersonalArea
import QuickBalance
import OpenCombine

final class SecurityAreaSectionsProvider {
    
    private let dependenciesResolver: DependenciesResolver & DependenciesInjector
    private var reloadCompletion: ((Bool) -> Void)?
    private var personalAreaQuickBalanceAction: PersonalAreaQuickBalanceAction
    private var personalAreaBiometryAction: PersonalAreaBiometryAction
    private let quickBalanceConfigurator: QuickBalanceConfigurator
    private var subscriptions: Set<AnyCancellable> = []
    private var isEnabledSantanderKey = false
    
    init(dependenciesResolver: DependenciesResolver & DependenciesInjector) {
        self.dependenciesResolver = dependenciesResolver
        self.personalAreaQuickBalanceAction = PersonalAreaQuickBalanceAction(dependenciesResolver: dependenciesResolver)
        self.personalAreaBiometryAction = PersonalAreaBiometryAction(dependenciesResolver: dependenciesResolver)
        self.quickBalanceConfigurator = QuickBalanceConfigurator(dependenciesResolver: dependenciesResolver)
        self.bindSantanderKey()
    }
}

extension SecurityAreaSectionsProvider: SecurityAreaActionProtocol {
    func getActions(userPref: UserPrefWrapper?,
                    offer: OfferEntity?,
                    deviceState: ValidatedDeviceStateEntity,
                    completion: @escaping ([SecurityActionViewModelProtocol]) -> Void) {
        guard let userPreference = userPref else {
            completion([])
            return
        }
        quickBalanceConfigurator.isQuickBalanceEnabled { [weak self] isQuickBalanceEnabled in
            guard let strongSelf = self else {return}
            strongSelf.personalAreaQuickBalanceAction = PersonalAreaQuickBalanceAction(dependenciesResolver: strongSelf.dependenciesResolver)
            strongSelf.personalAreaBiometryAction = PersonalAreaBiometryAction(dependenciesResolver: strongSelf.dependenciesResolver)
            let views = SecurityActionBuilder(userPreference)
                .addPhone()
                .addMail()
                .addBiometrySystem(customAction: strongSelf.personalAreaBiometryAction.didSelectBiometry)
                .addGeolocation()
                .addVideo(offer)
                .addSecureDevice(deviceState, offer, strongSelf.isEnabledSantanderKey)
                .addUser()
                .addQuickBalance(
                    isQuickBalanceEnabled: isQuickBalanceEnabled,
                    action: strongSelf.personalAreaQuickBalanceAction
                )
                .addPasswordSignatureKey()
                .addSignatureKey()
                .build()
            completion(views)
        }
    }
}

private extension SecurityAreaSectionsProvider {
    func bindSantanderKey() {
        let booleanFeatureFlag: BooleanFeatureFlag = dependenciesResolver.resolve()
        booleanFeatureFlag.fetch(SpainFeatureFlag.santanderKey)
            .sink { [unowned self] result in
                self.isEnabledSantanderKey = result
            }
            .store(in: &subscriptions)
    }
}
