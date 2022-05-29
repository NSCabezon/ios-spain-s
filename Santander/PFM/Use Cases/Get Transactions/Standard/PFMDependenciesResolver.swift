//
//  PFMDependenciesResolver.swift
//  Santander
//
//  Created by José Carlos Estela Anguita on 1/2/22.
//

import Foundation
import CoreFoundationLib
import CoreDomain

protocol PFMDependenciesResolver {
    func resolve() -> PfmHelperProtocol
    func resolve() -> PFMTransactionsHandler
    func resolve() -> GlobalPositionDataRepository
}
