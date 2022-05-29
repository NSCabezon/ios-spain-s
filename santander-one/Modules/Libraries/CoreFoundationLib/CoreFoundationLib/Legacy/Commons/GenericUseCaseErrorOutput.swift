//
//  GenericUseCaseErrorOutput.swift
//  Commons
//
//  Created by Carlos Monfort Gómez on 01/09/2020.
//

import Foundation

public class GenericUseCaseErrorOutput: StringErrorOutput {
    public let errorCode: String?
    
    public init(_ errorDesc: String?, _ errorCode: String?) {
        self.errorCode = errorCode
        super.init(errorDesc)
    }
}
