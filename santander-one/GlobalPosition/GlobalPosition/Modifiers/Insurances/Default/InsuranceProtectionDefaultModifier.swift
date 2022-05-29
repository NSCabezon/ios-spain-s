//
//  InsuranceProtectionDefaultModifier.swift
//  Account
//
//  Created by Ernesto Fernandez Calles on 14/2/22.
//

import CoreFoundationLib

public class InsuranceProtectionDefaultModifier: InsuranceProtectionModifier {
    public override func didSelectInsuranceProtection(insurance: InsuranceProtectionEntity) {
        if self.next == nil {
            self.globalPositionDelegateDidSelectInsuranceProtection(insurance: insurance)
        } else {
            super.didSelectInsuranceProtection(insurance: insurance)
        }
    }

    override func addExtraModifier() {
        self.completion?(self.dependenciesResolver)
    }
}

private extension InsuranceProtectionDefaultModifier {
    func globalPositionDelegateDidSelectInsuranceProtection(insurance: InsuranceProtectionEntity) {
        self.dependenciesResolver.resolve(for: GlobalPositionModuleCoordinatorDelegate.self)
            .didSelectInsuranceProtection(insurance: insurance)
    }
}
