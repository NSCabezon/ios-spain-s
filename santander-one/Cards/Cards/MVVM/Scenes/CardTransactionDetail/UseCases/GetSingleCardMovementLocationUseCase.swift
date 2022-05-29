//
//  GetSingleCardMovementLocationUseCase.swift
//  Cards
//
//  Created by Hernán Villamil on 30/3/22.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib

public protocol GetSingleCardMovementLocationUseCase {
    func fetchSingleCardMovementLocation(card: CardRepresentable,
                                         transaction: CardTransactionRepresentable,
                                         transactionDetail: CardTransactionDetailRepresentable?) -> AnyPublisher<CardSingleCardMovementRepresentable, Error>
}

struct DefaultGetSingleCardMovementLocationUseCase {
    private let repository: CardRepository
    
    init(dependencies: CardTransactionDetailExternalDependenciesResolver) {
        repository = dependencies.resolve()
    }
}

extension DefaultGetSingleCardMovementLocationUseCase: GetSingleCardMovementLocationUseCase {
    func fetchSingleCardMovementLocation(card: CardRepresentable, transaction: CardTransactionRepresentable, transactionDetail: CardTransactionDetailRepresentable?) -> AnyPublisher<CardSingleCardMovementRepresentable, Error> {
        return  repository.loadCardSingleMovementLocation(card: card, transaction: transaction, transactionDetail: transactionDetail)
            .map(getSingleCardMovement)
            .eraseToAnyPublisher()
        }
}

private extension DefaultGetSingleCardMovementLocationUseCase {
    func getSingleCardMovement(cardMovement: CardMovementLocationRepresentable) -> CardSingleCardMovementRepresentable {
        let location = Location(latitude: cardMovement.latitude, longitude: cardMovement.longitude)
        return CardSingleMovement(location: cardMovement, status: checkStatus(cardMovement.status ?? "", location: location))
    }
    
    struct Location {
        let latitude: Double?
        let longitude: Double?
    }
    
    struct CardSingleMovement: CardSingleCardMovementRepresentable {
        var location: CardMovementLocationRepresentable
        var status: CardMovementLocationUseType
        init(location: CardMovementLocationRepresentable, status: CardMovementLocationUseType) {
            self.location = location
            self.status = status
        }
    }

    func checkStatus(_ status: String, location: Location) -> CardMovementLocationUseType {
        switch status {
        case "200", "201":
            return hasLocationOK(location) ? .locatedMovement : .notLocatedMovement
        case "206", "207":
            return .onlineMovement
        case "208", "209":
            return .neverLocalizable
        default:
            return .serviceError
        }
    }
    
    func hasLocationOK(_ location: Location) -> Bool {
        guard let latitude = location.longitude, latitude != 0, let longitude = location.longitude, longitude != 0 else {
            return false
        }
        return true
    }
}


