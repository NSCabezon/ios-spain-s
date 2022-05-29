//
//  RepositoryResponseMock.swift
//  UnitTestCommons
//
//  Created by César González Palomino on 20/10/2020.
//

import Foundation
import CoreFoundationLib

public final class RepositoryResponseMock<Type>: RepositoryResponse<Type> {
    
    let type: Type?
    
    init(_ type: Type? = nil) {
        self.type = type
    }
    
    override public func isSuccess() -> Bool {
        return true
    }
    
    override public func getResponseData() throws -> Type? {
        return self.type
    }
    
    override public func getErrorCode() throws -> CLong {
        return 0
    }
    
    override public func getErrorMessage() throws -> String {
        return "Can't load the the data"
    }
}
