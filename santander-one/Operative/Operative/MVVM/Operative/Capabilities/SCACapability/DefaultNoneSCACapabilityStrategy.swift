//
//  DefaultNoneSCACapabilityStrategy.swift
//  Operative
//
//  Created by José Carlos Estela Anguita on 25/1/22.
//

import Foundation
import CoreDomain
import OpenCombine

struct DefaultNoneSCACapabilityStrategy<Operative: ReactiveOperative>: SCACapabilityStrategy {
    
    let operative: Operative
    
    func scaPublisher(for sca: SCARepresentableType) -> AnyPublisher<Void, Error> {
        return Future { promise in
            switch sca {
            case .none(let type):
                operative.coordinator.dataBinding.set(type)
                promise(.success(()))
            default:
                promise(.failure(ReactiveOperativeError.unknown))
            }
        }
        .eraseToAnyPublisher()
    }
}
