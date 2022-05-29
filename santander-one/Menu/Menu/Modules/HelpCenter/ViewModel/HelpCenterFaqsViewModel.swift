//
//  HelpCenterFaqsViewModel.swift
//  Menu
//
//  Created by Carlos Gutiérrez Casado on 25/02/2020.
//

import Foundation
import CoreFoundationLib

struct HelpCenterFaqsViewModel {
    let isVirtualAssistantEnabled: Bool
    let faqs: [HelpCenterFaqItemViewModel]
}

struct HelpCenterFaqItemViewModel {
    let question: LocalizedStylableText
    let answer: LocalizedStylableText
    
    init(_ entity: FaqsEntity) {
        self.question = localized(entity.question)
        self.answer = localized(entity.answer)
    }
}
