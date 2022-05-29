//
//  SpainAccountOtherOperativesActionModifier.swift
//  Santander
//
//  Created by José María Jiménez Pérez on 13/4/21.
//

import Foundation
import Account
import CoreFoundationLib
import Bizum

final class SpainAccountOtherOperativesActionModifier {
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension SpainAccountOtherOperativesActionModifier: AccountOtherOperativesActionModifierProtocol {    
    func didSelectAction(_ action: AccountActionType, _ entity: AccountEntity) {
        didSelectAccountAction(action, entity)
    }
    
    func didSelectAccountAction(_ action: AccountActionType, _ entity: AccountEntity) {
        switch action {
        case let .custome(actionId, _, _, _, _, _, _):
            if actionId == "bizum" {
                let coordinator: BizumStartCapable = dependenciesResolver.resolve(for: BizumStartCapable.self)
                coordinator.launchBizum()
            }
        default:
            self.dependenciesResolver.resolve(for: AccountsHomeCoordinatorDelegate.self).didSelectAction(action: action, entity: entity)
        }
    }
}
