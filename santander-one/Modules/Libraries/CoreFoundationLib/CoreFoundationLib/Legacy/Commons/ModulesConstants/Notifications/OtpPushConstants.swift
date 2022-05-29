//
//  OtpPushConstants.swift
//  Commons
//
//  Created by Carlos Monfort Gómez on 26/5/21.
//

import Foundation

public struct OtpPushPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "otp_push_actualizar_token"
    public enum Action: String {
        case error
        case ok
    }
    public init() {}
}
