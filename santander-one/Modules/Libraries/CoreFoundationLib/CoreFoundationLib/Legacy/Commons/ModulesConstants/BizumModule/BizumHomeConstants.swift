//
//  BizumHomeConstants.swift
//  Commons
//
//  Created by Carlos Monfort Gómez on 04/02/2021.
//

import Foundation

public struct BizumHomeConstants {
    public static let bizumDefaultXPAN = "bizumDefaultXPAN"
}

public struct BizumHomeOffers {
    public static let bizumPayGroup = "BIZUM_GROUP_SPLIT"
    public static let bizumFundSent = "BIZUM_FUND_SENT"
}

public struct BizumHomePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum"

    public enum Action: String {
        case register = "alta"
        case newSend = "nuevo_envio"
        case settings = "ajustes"
        case contacts = "contactos"
        case operationsButton = "ver_historico"
        case operationsList = "ver_todos"
        case clickFavourite = "click_favourite"
    }
    
    public init() {}
}
