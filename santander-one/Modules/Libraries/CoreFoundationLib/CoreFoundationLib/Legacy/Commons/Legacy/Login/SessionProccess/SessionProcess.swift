//
//  fsdf.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 11/20/20.
//

import Foundation

public enum SessionManagerProcessEvent {
    case loadDataSuccess
    case fail(error: LoadSessionError)
    case updateLoadingMessage(isPb: Bool, globalPositionName: String)
    case cancelByUser
}
