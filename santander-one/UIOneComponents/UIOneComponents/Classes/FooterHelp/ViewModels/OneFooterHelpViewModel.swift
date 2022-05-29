//
//  OneFooterHelpViewModel.swift
//  UIOneComponents
//
//  Created by Cristobal Ramos Laina on 23/11/21.
//

import CoreFoundationLib

public class OneFooterHelpViewModel {
    public let faqs: [FaqsViewModel]?
    public let tips: [OfferTipViewModel]?
    public let showVirtualAssistant: Bool
    
    public init(faqs: [FaqsViewModel]?, tips: [OfferTipViewModel]?, showVirtualAssistant: Bool) {
        self.faqs = faqs
        self.tips = tips
        self.showVirtualAssistant = showVirtualAssistant
    }
}
