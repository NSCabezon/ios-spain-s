//
//  BizumRefundMoneyConstants.swift
//  Commons
//
//  Created by José Carlos Estela Anguita on 10/12/20.
//

import Foundation


public struct BizumRefundMoneySignaturePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum_devolver_envio_recibido_firma"
    public enum Action: String {
        case error
    }
    public init() {}
}

public struct BizumRefundMoneyOTPPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum_devolver_envio_recibido_otp"
    public enum Action: String {
        case error
    }
    public init() {}
}

public struct BizumRefundMoneySummaryPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "bizum_devolver_envio_recibido_resumen"
    public enum Action: String {
        case share = "compartir"
    }
    public init() {}
}

public struct BizumRefundMoneyConfirmationPage: PageTrackable {
    public let page = "bizum_devolver_envio_recibido_confirmación"
    public init() {}
}
