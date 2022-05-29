//
//  GetSendMoneyActionsUseCase.swift
//  Transfer
//
//  Created by Carlos Monfort Gómez on 21/12/21.
//

import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetSendMoneyActionsUseCase {
    func fetchSendMoneyActions(_ locations: [PullOfferLocation], page: String?) -> AnyPublisher<[SendMoneyHomeActionType], Never>
}

public struct DefaultGetSendMoneyActionsUseCase {
    public init() {}
}

extension DefaultGetSendMoneyActionsUseCase: GetSendMoneyActionsUseCase {
    public func fetchSendMoneyActions(_ locations: [PullOfferLocation], page: String?) -> AnyPublisher<[SendMoneyHomeActionType], Never> {
        return Just([])
            .eraseToAnyPublisher()
    }
}
