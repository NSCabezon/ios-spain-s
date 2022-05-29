//
//  BizumOperationsAppConfig.swift
//  Bizum
//
//  Created by Boris Chirino Fernandez on 16/12/2020.
//

import Foundation

final class BizumAppConfigOperationsStatus {
    public let accept: Bool
    public let refund: Bool
    public let cancelNotRegistered: Bool
    
    public init(accept: Bool, refund: Bool, cancelNotRegistered: Bool) {
        self.accept = accept
        self.refund = refund
        self.cancelNotRegistered = cancelNotRegistered
    }
}
