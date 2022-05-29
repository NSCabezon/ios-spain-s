//
//  BizumRequestMoneyConstants.swift
//  Commons
//
//  Created by Jose Ignacio de Juan Díaz on 10/12/2020.
//

import Foundation

public struct BizumRequestMoneyConfirmationPage: PageWithActionTrackable {
    public let page = "bizum_solicitar_dinero_confirmacion"
    public init() {}
}

public struct BizumRequestMoneySummaryPage: PageWithActionTrackable {
    public let page = "bizum_solicitar_dinero_resumen"
    public typealias ActionType = Action
    public enum Action: String {
        case share = "compartir"
    }
    public init() {}
}

public struct BizumAmountPage: PageWithActionTrackable {
    public let strategy: TrackerPageAssociated?
    public let page: String

    public init(strategy: TrackerPageAssociated? = nil) {
        self.strategy = strategy
        self.page = strategy?.pageAssociated ?? ""
    }
}
