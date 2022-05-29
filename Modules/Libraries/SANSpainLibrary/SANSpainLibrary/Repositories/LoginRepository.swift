//
//  LoginRepository.swift
//  SANSpainLibrary
//
//  Created by José Carlos Estela Anguita on 17/5/21.
//

import CoreDomain

public protocol LoginRepository {
    func loginWithUser(_ userName: String, magic: String, type: LoginTypeRepresentable) throws -> Result<Void, Error>
}
