//
//  CardHistoricExtractConstants.swift
//  Commons
//
//  Created by Ignacio González Miró on 23/11/2020.
//

import Foundation

public struct CardHistoricExtractPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/card/next_settlement/history"
    public enum Action: String {
        case extractPdf = "view_pdf_settlement"
        case shoppingMap = "view_purchase_map"
        case monthSelector = "change_month_selector"
    }
    public init() {}
}
