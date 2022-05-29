//
//  ClientsProvider.swift
//  SANServicesLibrary
//
//  Created by José Carlos Estela Anguita on 17/5/21.
//

import Foundation
import SANServicesLibrary

public protocol ClientsProvider {
    func update(client: NetworkClient)
}
