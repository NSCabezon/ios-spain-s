//
//  InternalTransferAmountViewTypeMapper.swift
//  TransferOperatives
//
//  Created by Marcos Álvarez Mesa on 15/3/22.
//

import Foundation

class InternalTransferAmountViewTypeMapper {

    static func map(transferType: InternalTransferType) -> InternalTransferAmountViewType {
        switch transferType {
        case .noExchange:
            return .noExchange
        case .simpleExchange(let sellExchange):
            return .simpleExchange(InternalTransferType.exchangeRateString(exchangeType: sellExchange))
        case .doubleExchange(let sellExchange, let buyExchange):
            return .doubleExchange(InternalTransferType.exchangeRateString(exchangeType: sellExchange),
                                   InternalTransferType.exchangeRateString(exchangeType: buyExchange))
        }
    }
}
