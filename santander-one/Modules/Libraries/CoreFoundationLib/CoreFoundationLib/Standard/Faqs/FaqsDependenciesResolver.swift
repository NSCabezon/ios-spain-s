//
//  FaqsDependenciesResolver.swift
//  CoreFoundationLib
//
//  Created by Angel Abad Perez on 13/4/22.
//

import Foundation
import OpenCombine
import CoreDomain

public protocol FaqsDependenciesResolver: CoreDependenciesResolver {
    func resolve() -> FaqsRepositoryProtocol
    func resolve() -> AppConfigRepositoryProtocol
    func resolve() -> GetOneFaqsUseCase
}

public extension FaqsDependenciesResolver {
    func resolve() -> GetOneFaqsUseCase {
        return DefaultGetOneFaqsUseCase(dependencies: self)
    }
}
