//
//  SendMoneyTransferTypes.swift
//  Models
//
//  Created by Angel Abad Perez on 26/10/21.
//

import CoreDomain

public protocol SendMoneyTransferTypeProtocol {
    var serviceString: String { get }
    var title: String? { get }
    var subtitle: String? { get }
}

public extension SendMoneyTransferTypeProtocol {
    var serviceString: String {
        return ""
    }
    
    var title: String? {
        return nil
    }
    
    var subtitle: String? {
        return nil
    }
}

open class SendMoneyTransferTypeFee {
    public let type: SendMoneyTransferTypeProtocol
    public var fee: AmountRepresentable?
    
    public init(type: SendMoneyTransferTypeProtocol, fee: AmountRepresentable?) {
        self.type = type
        self.fee = fee
    }
}
