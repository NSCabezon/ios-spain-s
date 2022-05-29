//
//  GlobalPositionConfiguration.swift
//  GlobalPosition
//
//  Created by Jose Carlos Estela Anguita on 07/11/2019.
//

import Foundation

public struct GlobalPositionConfiguration {
    
    let isInsuranceBalanceEnabled: Bool
    let isCounterValueEnabled: Bool
    
    public init(isInsuranceBalanceEnabled: Bool, isCounterValueEnabled: Bool) {
        self.isInsuranceBalanceEnabled = isInsuranceBalanceEnabled
        self.isCounterValueEnabled = isCounterValueEnabled
    }
}
