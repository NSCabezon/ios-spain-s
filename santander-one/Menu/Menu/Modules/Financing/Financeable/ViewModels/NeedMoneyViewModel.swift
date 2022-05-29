//
//  NeedMoneyViewModel.swift
//  Menu
//
//  Created by Carlos Monfort Gómez on 13/07/2020.
//

import Foundation
import CoreFoundationLib

struct NeedMoneyViewModel {
    private let viewModel: FinanceableInfoViewModel.NeedMoney

    init(_ viewModel: FinanceableInfoViewModel.NeedMoney) {
        self.viewModel = viewModel
    }

    var amount: String? {
        guard let amount = viewModel.amount else { return nil }
        return amount.getFormattedValue(withDecimals: 0)
    }
    
    var amountWithCurrency: String? {
        guard let amount = viewModel.amount,
              let currency = amount.currency
        else {
            return nil
        }
        return amount.getFormattedValue(withDecimals: 0) + currency
    }
    
    var offer: OfferEntity? {
        return viewModel.offer?.offer
    }
    
    var imageURL: String? {
        return self.offer?.banner?.dto.url
    }
    
    var isAmountViewHidden: Bool {
        guard self.amount != nil else { return true }
        return false
    }
    
    var isOfferViewHidden: Bool {
        guard self.offer != nil else { return true }
        return false
    }
    
    var offerViewModel: OfferEntityViewModel? {
        guard let offer = self.offer else { return nil }
        return OfferEntityViewModel(entity: offer)
    }
}
