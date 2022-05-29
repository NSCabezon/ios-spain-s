//
//  PendingTransactionDetailActionBuilder.swift
//  Cards
//
//  Created by Juan Carlos López Robles on 9/17/20.
//
import CoreFoundationLib
import Foundation

final class PendingTransactionDetailActionBuilder {
    let entity: CardEntity
    var actions = [CardActionViewModel]()
    private var dependenciesResolver: DependenciesResolver
    private var actionsModifier: CardTransactionDetailActionsEnabledModifierProtocol? {
        return self.dependenciesResolver.resolve(forOptionalType: CardTransactionDetailActionsEnabledModifierProtocol.self)
    }
    
    init(entity: CardEntity, dependenciesResolver: DependenciesResolver) {
        self.entity = entity
        self.dependenciesResolver = dependenciesResolver
    }
    
    func addOn(_ action: @escaping (OldCardActionType, CardEntity) -> Void) {
        guard entity.isDisabled else { return }
        let onAction = CardActionViewModel(
            entity: entity,
            type: .onCard,
            action: action
        )
        actions.append(onAction)
    }
    
    func addOff(_ action: @escaping (OldCardActionType, CardEntity) -> Void) {
        guard !entity.isDisabled else { return }
        let offAction = CardActionViewModel(
            entity: entity,
            type: .offCard,
            action: action
        )
        actions.append(offAction)
    }
    
    func addEnable(_ action: @escaping (OldCardActionType, CardEntity) -> Void) {
        guard entity.isInactive else { return }
        let enable = CardActionViewModel(
            entity: entity,
            type: .enable,
            action: action
        )
        actions.append(enable)
    }
    
    func addDirectMoney(_ action: @escaping (OldCardActionType, CardEntity) -> Void) {
        guard let directMoneyAction = self.actionsModifier?.directMoneyAction, directMoneyAction == true else { return }
        let action = CardActionViewModel(
            entity: entity,
            type: .instantCash,
            action: action,
            isDisabled: entity.isDisabled
        )
        actions.append(action)
    }
    
    func addShare(viewModel: PendingTransactionDetailViewModel, _ action: @escaping (OldCardActionType, CardEntity) -> Void) {
        let share = CardActionViewModel(
            entity: entity,
            type: .share(viewModel),
            action: action
        )
        actions.append(share)
    }
    
    func build() -> [CardActionViewModel] {
        return self.actions
    }
}
