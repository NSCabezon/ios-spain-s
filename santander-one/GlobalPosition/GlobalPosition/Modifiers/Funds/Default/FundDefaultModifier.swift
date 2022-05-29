//
//  FundDefaultModifier.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 2/3/21.
//

import CoreFoundationLib
import Foundation

public class FundDefaultModifier: FundModifier {
    public override func didSelectFund(fund: FundEntity) {
        if self.next == nil {
            self.globalPositionDelegateDidSelectFund(fund: fund)
        } else {
            super.didSelectFund(fund: fund)
        }
    }
    
    override func addExtraModifier() {
        self.completion?(self.dependenciesResolver)
    }
}

private extension FundDefaultModifier {
    func globalPositionDelegateDidSelectFund(fund: FundEntity) {
        self.dependenciesResolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self)
            .didSelectFund(fund: fund)
    }
}
