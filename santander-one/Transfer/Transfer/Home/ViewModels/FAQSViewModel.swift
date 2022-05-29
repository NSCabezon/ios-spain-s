//
//  FAQSViewModel.swift
//  Transfer
//
//  Created by Cristobal Ramos Laina on 24/02/2020.
//

import Foundation
import CoreFoundationLib

class TransfersFaqsViewModel {
    let entity: FaqsEntity
    
    init(_ entity: FaqsEntity) {
        self.entity = entity
    }
    
    var question: String {
        return entity.question
    }
    
    var answer: String {
        return entity.answer
    }
}
