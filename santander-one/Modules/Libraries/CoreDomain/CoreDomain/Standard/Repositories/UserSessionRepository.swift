//
//  UserSessionRepository.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 31/5/21.
//

import Foundation

public protocol UserSessionRepository {
    func cleanSession()
    func saveToken(_ token: String)
    func saveUserData(_ userData: UserDataRepresentable?)
    func saveIsPB(_ isPB: Bool)
}
