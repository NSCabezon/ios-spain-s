//
//  BizumAcceptMoneyResume.swift
//  Commons
//
//  Created by Boris Chirino Fernandez on 03/12/2020.
//

import Foundation

public struct BizumAcceptMoneyResumePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum_aceptar_solicitud_dinero_resumen"
    public enum Action: String {
        case share = "compartir"
    }
    public init() {}
}

public struct BizumAcceptRequestMoneyConfirmationPage: PageTrackable {
    public let page = "bizum_aceptar_solicitud_dinero_confirmación"
    public init() {}
}

public struct BizumAcceptRequestMoneySignaturePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum_aceptar_solicitud_dinero_firma"
    public enum Action: String {
        case error
    }
    public init() {}
}

public struct BizumAcceptRequestMoneyOTPPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum_aceptar_solicitud_dinero_otp"
    public enum Action: String {
        case error
    }
    public init() {}
}
