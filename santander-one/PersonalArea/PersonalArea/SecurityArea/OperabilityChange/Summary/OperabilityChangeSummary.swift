//
//  OperabilityChangeSummary.swift
//  PersonalArea
//
//  Created by David Gálvez Alonso on 18/05/2020.
//

import CoreFoundationLib

class OperabilityChangeSummaryFooterBuilder {
    
    let operativeData: OperabilityChangeOperativeData
    var items: [SummaryFooterItemViewModel] = []

    init(operativeData: OperabilityChangeOperativeData) {
        self.operativeData = operativeData
    }
    
    func addGoToSendMoney(action: @escaping () -> Void) {
        let item = SummaryFooterItemViewModel(image: "icnEnviarDinero", title: localized("generic_button_anotherSendMoney"), action: action)
        self.items.append(item)
    }
    
    func addGoToGlobalPosition(action: @escaping () -> Void) {
        let item = SummaryFooterItemViewModel(image: "icnHome", title: localized("generic_button_globalPosition"), action: action)
        self.items.append(item)
    }
    
    func addGoToOpinator(action: @escaping () -> Void) {
        let item = SummaryFooterItemViewModel(image: "icnLike", title: localized("generic_button_improve"), action: action)
        self.items.append(item)
    }
    
    func build() -> [SummaryFooterItemViewModel] {
        return self.items
    }
}
