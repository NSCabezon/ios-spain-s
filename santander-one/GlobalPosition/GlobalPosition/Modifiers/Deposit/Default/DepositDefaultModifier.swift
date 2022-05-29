//
//  DepositDefaultModifier.swift
//  GlobalPosition
//
//  Created by Juan Carlos López Robles on 2/2/21.
//

import CoreFoundationLib

public class DepositDefaultModifier: DepositModifier {
    public override func didSelectDeposit(deposit: DepositEntity) {
        if self.next == nil {
            self.globalPositionDelegateDidSelectDeposit(deposit: deposit)
        } else {
            super.didSelectDeposit(deposit: deposit)
        }
    }
    
    override func addExtraModifier() {
        self.completion?(self.dependenciesResolver)
    }
}

private extension DepositDefaultModifier {
    func globalPositionDelegateDidSelectDeposit(deposit: DepositEntity) {
        self.dependenciesResolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self)
            .didSelectDeposit(deposit: deposit)
    }
}
