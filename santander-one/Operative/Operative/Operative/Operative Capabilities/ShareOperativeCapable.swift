//
//  OperativeShareCapable.swift
//  Operative
//
//  Created by Laura González on 16/12/2020.
//

import Foundation
import UI

public enum ShareOperativeError: Error {
    case generalError
}

public protocol ShareOperativeCapable {
    func getShareView(completion: @escaping (Result<(UIShareView?, UIView?), ShareOperativeError>) -> Void)
}
