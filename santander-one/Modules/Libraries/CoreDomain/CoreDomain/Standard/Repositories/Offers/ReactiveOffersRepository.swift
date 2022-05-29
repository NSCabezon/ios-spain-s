//
//  ReactiveOffersRepository.swift
//  CoreDomain
//
//  Created by José Carlos Estela Anguita on 15/12/21.
//

import Foundation
import OpenCombine

public protocol ReactiveOffersRepository {
    func fetchOffersPublisher() -> AnyPublisher<[OfferRepresentable], Never>
}
