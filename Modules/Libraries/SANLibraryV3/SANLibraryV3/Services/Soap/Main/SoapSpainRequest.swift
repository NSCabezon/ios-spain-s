//
//  SoapSpainRequest.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 18/5/21.
//

import Foundation
import SANServicesLibrary

struct SoapSpainRequest<Input: SoapBodyConvertible>: NetworkRequest {
    var method: String
    let serviceName: String
    let url: String
    let headers: [String : String] = [:]
    let input: Input
    var body: String {
        return self.input.body.replacingOccurrences(of: "\n", with: "")
    }
}
