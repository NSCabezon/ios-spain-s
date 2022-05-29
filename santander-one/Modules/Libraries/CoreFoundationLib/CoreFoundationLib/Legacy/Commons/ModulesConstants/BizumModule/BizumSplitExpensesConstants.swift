//
//  BizumSplitExpensesConstants.swift
//  Commons
//
//  Created by Carlos Monfort Gómez on 14/01/2021.
//

import Foundation

public struct BizumSplitExpensesConfirmationPage: PageWithActionTrackable {
    public let page = "bizum_dividir_gasto_confirmacion"
    public init() {}
}

public struct BizumSplitExpensesSummaryPage: PageWithActionTrackable {
    public let page = "bizum_dividir_gasto_resumen"
    public typealias ActionType = Action
    public enum Action: String {
        case share = "compartir"
    }
    public init() {}
}

public struct BizumSplitExpensesAmountPage: PageWithActionTrackable {
    public let page = "bizum_dividir_gasto"
    public typealias ActionType = Action
    public enum Action: String {
        case addNewManuallyTypedNumber = "numero"
        case phoneBook = "agenda"
        case frequentContact = "contacto_frecuente"
        case addMoreContacts = "añadir_mas"
        case removeContact = "eliminar_contacto"
        case confirmRemoveContact = "confirmar_eliminar_contacto"
    }
    public init() {}
}

public struct BizumSplitExpensesInvitation {
    public static let page = "bizum_dividir_gasto_invitar"
    public struct Action {
        public static let invite = "invitar"
    }
}
