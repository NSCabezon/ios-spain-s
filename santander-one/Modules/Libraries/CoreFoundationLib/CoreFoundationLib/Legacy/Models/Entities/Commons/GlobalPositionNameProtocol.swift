//
//  GlobalPositionNameProtocol.swift
//  RetailClean
//
//  Created by Carlos Monfort Gómez on 01/10/2020.
//  Copyright © 2020 Ciber. All rights reserved.
//

import Foundation
import SANLegacyLibrary
import CoreDomain

public protocol GlobalPositionNameProtocol {
    var globalPositionDataRepresentable: GlobalPositionDataRepresentable { get }
    var name: String { get }
    var availableName: String { get }
    var initials: String? { get }
}

public extension GlobalPositionNameProtocol {
    var name: String {
        if let name = globalPositionDataRepresentable.clientNameWithoutSurname, !name.isEmpty {
            return name
        }
        return globalPositionDataRepresentable.clientName ?? ""
    }
    var availableName: String {
        guard let name = globalPositionDataRepresentable.clientNameWithoutSurname,
              let lastName = globalPositionDataRepresentable.clientFirstSurnameRepresentable,
              !name.isEmpty, !lastName.isEmpty else {
                  return globalPositionDataRepresentable.clientName ?? ""
              }
              return "\(name) \(lastName)"
    }
    var fullName: String {
        guard let name: String = globalPositionDataRepresentable.clientNameWithoutSurname,
                let firstSurnameName = globalPositionDataRepresentable.clientFirstSurnameRepresentable,
                let secondSurnameName = globalPositionDataRepresentable.clientSecondSurnameRepresentable,
                !name.isEmpty, !firstSurnameName.isEmpty else {
            return globalPositionDataRepresentable.clientName ?? ""
        }
        return "\(name) \(firstSurnameName) \(secondSurnameName)"
    }
    
    var initials: String? {
        if let firstName = globalPositionDataRepresentable.clientNameWithoutSurname,
            let lastName = globalPositionDataRepresentable.clientFirstSurnameRepresentable,
            !firstName.isEmpty, !lastName.isEmpty {
            let first: String = "\(firstName.first ?? " ")"
            let second: String = "\(lastName.first ?? " ")"
            return first + second
        } else if let clientName = globalPositionDataRepresentable.clientName {
            let parts = clientName.split(separator: " ")
            guard parts.count > 1, !parts[0].isEmpty, !parts[1].isEmpty else { return "\(clientName.first ?? " ")" }
            return "\(parts[0].first ?? " ")\(parts[1].first ?? " ")"
        } else {
            return nil
        }
    }
}
