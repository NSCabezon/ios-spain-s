//
//  InternalTransferSummaryFooterBuilder.swift
//  TransferOperatives
//
//  Created by Carlos Monfort Gómez on 14/3/22.
//

import CoreFoundationLib
import OpenCombine

final class InternalTransferSummaryFooterBuilder {
    private var footerItems: [OneFooterNextStepItemViewModel] = []
    private var subscriptions = Set<AnyCancellable>()
    
    init(subscriptions: inout Set<AnyCancellable>) {
        self.subscriptions = subscriptions
    }
    
    func addSendMoney(_ action: @escaping () -> Void) {
        let stepItem = OneFooterNextStepItemViewModel(
            titleKey: "generic_button_anotherSendMoney",
            imageName: "oneIcnTransfer",
            accessibilitySuffix: "_0"
        )
        stepItem.subject
            .sink(receiveValue: action)
            .store(in: &subscriptions)
        footerItems.append(stepItem)
    }
    
    func addGlobalPosition(_ action: @escaping () -> Void) {
        let stepItem = OneFooterNextStepItemViewModel(
            titleKey: "generic_button_globalPosition",
            imageName: "oneIcnPg",
            accessibilitySuffix: "_1"
        )
        stepItem.subject
            .sink(receiveValue: action)
            .store(in: &subscriptions)
        footerItems.append(stepItem)
    }
    
    func addHelp(_ action: @escaping () -> Void) {
        let stepItem = OneFooterNextStepItemViewModel(
            titleKey: "generic_button_improve",
            imageName: "oneIcnOk",
            accessibilitySuffix: "_2"
        )
        stepItem.subject
            .subscribe(on: Schedulers.main)
            .sink(receiveValue: action)
            .store(in: &subscriptions)
        footerItems.append(stepItem)
    }
    
    func build() -> OneFooterNextStepViewModel {
        return OneFooterNextStepViewModel(
            titleKey: "summary_label_nowThat",
            elements: self.footerItems
        )
    }
}
