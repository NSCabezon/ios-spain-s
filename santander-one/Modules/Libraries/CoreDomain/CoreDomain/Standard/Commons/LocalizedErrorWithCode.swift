//
//  ErrorWithCode.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 2/6/21.
//

import Foundation

public protocol LocalizedErrorWithCode: LocalizedError {
    var code: Int { get }
    var errorCode: String { get }
}

extension NSError: LocalizedErrorWithCode {
    public enum Constants {
        public static let errorCodeKey = "errorCodeKey"
    }
    public var errorCode: String {
        guard let errorCode = userInfo[Constants.errorCodeKey] as? String else {
            return ""
        }
        return errorCode
    }
}
