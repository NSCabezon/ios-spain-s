//
//  SavingsCheckNewHomeSendMoneyIsEnabledUseCase.swift
//  SavingProducts
//
//  Created by Jose Servet Font on 19/5/22.
//

import Foundation
import OpenCombine

public protocol SavingsCheckNewHomeSendMoneyIsEnabledUseCase {
    func fetchEnabled() -> AnyPublisher<Bool, Never>
}

struct DefaultSavingsCheckNewHomeSendMoneyIsEnabledUseCase {
}

extension DefaultSavingsCheckNewHomeSendMoneyIsEnabledUseCase: SavingsCheckNewHomeSendMoneyIsEnabledUseCase {
    func fetchEnabled() -> AnyPublisher<Bool, Never> {
        return Just(false).eraseToAnyPublisher()
    }
}
