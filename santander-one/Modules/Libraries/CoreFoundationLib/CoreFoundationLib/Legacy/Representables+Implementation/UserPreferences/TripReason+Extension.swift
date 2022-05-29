//
//  TripReason+Extension.swift
//  CoreFoundationLib
//
//  Created by Jose Ignacio de Juan Díaz on 29/12/21.
//

import CoreDomain

public extension TripReason {
    var trackEvent: String {
        switch self {
        case .business:
            return "negocios"
        case .pleasure:
            return "placer"
        }
    }
}
