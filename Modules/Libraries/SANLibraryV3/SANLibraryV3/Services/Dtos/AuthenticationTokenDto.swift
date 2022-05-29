//
//  AuthenticationTokenDto.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 18/5/21.
//

import Foundation
import SANServicesLibrary

struct AuthenticationTokenDto {
    let token: String
}

extension AuthenticationTokenDto: XMLDecodable {
    
    init?(decoder: XMLDecoder) {
        guard
            let token: String = decoder.decode(key: "tokenCredential")
        else {
            return nil
        }
        self.token = token
    }
}
