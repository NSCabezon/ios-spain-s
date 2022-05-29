//
//  PaymentViewModel.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 13/04/2020.
//

import Foundation

final class PaymentViewModel {
    let title: String
    let description: String
    let imageName: String
    let type: BillsAndTaxesTypeOperativePayment
    
    init(title: String, description: String, imageName: String, type: BillsAndTaxesTypeOperativePayment) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.type = type
    }
}
