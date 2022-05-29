//
//  PersonalAreaSections.swift
//  Santander
//
//  Created by Rubén Márquez Fernández on 15/4/21.
//

import CoreFoundationLib
import PersonalArea
import QuickBalance

final class PersonalAreaSectionsProvider {
    
    private let dependenciesResolver: DependenciesResolver & DependenciesInjector
    private var reloadCompletion: ((Bool) -> Void)?
    private var personalAreaQuickBalanceAction: PersonalAreaQuickBalanceAction
    private var personalAreaBiometryAction: PersonalAreaBiometryAction
    private let quickBalanceConfigurator: QuickBalanceConfigurator
    
    init(dependenciesResolver: DependenciesResolver & DependenciesInjector) {
        self.dependenciesResolver = dependenciesResolver
        self.personalAreaQuickBalanceAction = PersonalAreaQuickBalanceAction(dependenciesResolver: dependenciesResolver)
        self.personalAreaBiometryAction = PersonalAreaBiometryAction(dependenciesResolver: dependenciesResolver)
        self.quickBalanceConfigurator = QuickBalanceConfigurator(dependenciesResolver: dependenciesResolver)
    }
}

extension PersonalAreaSectionsProvider: PersonalAreaSectionsProtocol {
    func getSecuritySectionCells(
        _ userPref: UserPrefWrapper?,
        completion: @escaping ([CellInfo]) -> Void) {
        quickBalanceConfigurator.isQuickBalanceEnabled { [weak self] isQuickBalanceEnabled in
            guard let strongSelf = self else { return }
            strongSelf.personalAreaQuickBalanceAction = PersonalAreaQuickBalanceAction(dependenciesResolver: strongSelf.dependenciesResolver)
            strongSelf.personalAreaBiometryAction = PersonalAreaBiometryAction(dependenciesResolver: strongSelf.dependenciesResolver)
            let cells = PersonalAreaSectionsSecurityBuilder(userPref: userPref, resolver: strongSelf.dependenciesResolver)
                .addBiometryCell(customAction: strongSelf.personalAreaBiometryAction.didSelectBiometry)
                .addGeoCell()
                .addSecureDeviceCell()
                .addOperativeUserCell()
                .addQuickBalanceCell(
                    isQuickBalanceEnabled: isQuickBalanceEnabled,
                    action: strongSelf.personalAreaQuickBalanceAction)
                .addChangePasswordCell()
                .addSignatureKeyCell()
                .addEditGDPRCell()
                .addLastAccessCell()
                .build()
            completion(cells)
        }

    }
}

private extension PersonalAreaSectionsProvider {
    var personalAreaCoordinator: PersonalAreaMainModuleCoordinatorDelegate? {
        self.dependenciesResolver.resolve(for: PersonalAreaMainModuleCoordinatorDelegate.self)
    }
}
