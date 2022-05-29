//
//  ReactiveRulesRepository.swift
//  CoreDomain
//
//  Created by José Carlos Estela Anguita on 20/12/21.
//

import Foundation
import OpenCombine

public protocol ReactiveRulesRepository {
    func fetchRulesPublisher() -> AnyPublisher<[RuleRepresentable], Never>
}
