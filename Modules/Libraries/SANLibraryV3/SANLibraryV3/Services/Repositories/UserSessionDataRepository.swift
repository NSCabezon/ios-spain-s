//
//  SessionRepository.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 31/5/21.
//

import CoreDomain
import SANServicesLibrary

struct UserSessionDataRepository: UserSessionRepository {
    
    let storage: Storage
    
    func cleanSession() {
        self.storage.clean()
    }

    func saveToken(_ token: String) {
        self.storage.store(AuthenticationTokenDto(token: token))
    }
    
    func saveUserData(_ userData: UserDataRepresentable?) {
        self.storage.store(userData)
    }
    
    func saveIsPB(_ isPB: Bool) {
        let sessionData = SessionData(isPB)
        self.storage.store(sessionData)
    }
}
