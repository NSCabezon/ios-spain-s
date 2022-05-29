//
//  StubException.swift
//  Loans-Unit-LoansTests
//
//  Created by Jose Carlos Estela Anguita on 05/11/2019.
//

import Foundation

public class StubException {
    
    let serviceName: String
    let exception: Error
    
    public init(for serviceName: String, exception: Error) {
        self.serviceName = serviceName
        self.exception = exception
    }
}
