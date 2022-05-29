//
//  ExampleGetDatedCardmovementsLocationsForShoppingMapUseCase.swift
//  Cards_Example
//
//  Created by Hernán Villamil on 22/2/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import CoreDomain
import OpenCombine
import CoreFoundationLib
import Cards
import SANLegacyLibrary

struct ExampleGetDatedCardMovementsLocationsForShoppingMapUseCase {
    private let dependencies: DependenciesResolver
    private var cardsManager: BSANCardsManager {
        dependencies.resolve(for: BSANManagersProvider.self).getBsanCardsManager()
    }
    
    init(dependencies: DependenciesResolver) {
        self.dependencies = dependencies
    }
}

extension ExampleGetDatedCardMovementsLocationsForShoppingMapUseCase: GetDatedCardMovementsLocationsForShoppingMapUseCase {
    func fetchLocationsForShoppingMap(card: CardRepresentable, startDate: Date, endDate: Date) -> AnyPublisher<[CardMovementLocationRepresentable], Never> {
        let output = getOutput(card: card, startDate: startDate, endDate: endDate)
        return Just(output)
            .eraseToAnyPublisher()
    }
}

private extension ExampleGetDatedCardMovementsLocationsForShoppingMapUseCase {
    func getOutput(card: CardRepresentable,
                   startDate: Date,
                   endDate: Date) -> [CardMovementLocationRepresentable] {
        var output = [CardMovementLocationRepresentable]()
        do {
            let cardEntity = CardEntity(card)
            let locationsListResponse = try cardsManager.getCardTransactionLocationsListByDate(card: cardEntity.dto,
                                                                                               startDate: startDate,
                                                                                               endDate: endDate)
            guard locationsListResponse.isSuccess(), let locationsRepresentables = try locationsListResponse.getResponseData() else {
                return output
            }
            let locationListRepresentables = filterLocations(locationsRepresentables.transactions)
            guard locationListRepresentables.count > 0 else {
                return output
            }
            output = locationListRepresentables
            return output
        } catch {
            return output
        }
    }
    
    func filterLocations(_ locations: [CardMovementLocationRepresentable]) -> [CardMovementLocationRepresentable]  {
        let groupedLocations = groupLocations(locations)
        let output = getLocationsForOutpu(groupedLocations)
        return output
    }

    func groupLocations(_ locations: [CardMovementLocationRepresentable]) -> [[CardMovementLocationRepresentable]] {
        var groupedLocations: [[CardMovementLocationRepresentable]] = []
        var locationList = locations.filter { $0.latitude != 0 || $0.longitude != 0 }
        while !locationList.isEmpty {
            let location = locationList[0]
            locationList.remove(at: 0)
            var indexFound: Int?
            for index in 0..<groupedLocations.count {
                let comparedItem = groupedLocations[index][0]
                if comparedItem.latitude == location.latitude, comparedItem.longitude == location.longitude {
                    indexFound = index
                    break
                }
            }
            if let index = indexFound {
                var items = groupedLocations[index]
                items.append(location)
                groupedLocations[index] = items
            } else {
                groupedLocations.append([location])
            }
        }
        return groupedLocations
    }

    func getLocationsForOutpu(_ groupedLocations: [[CardMovementLocationRepresentable]]) -> [CardMovementLocationRepresentable] {
        var output: [CardMovementLocationRepresentable] = []
        for locations in groupedLocations {
            if locations.count > 1 {
                let distanceFromContestedLocation: Double = 3.0 * Double(locations.count) / 2.0
                let radiansBetweenAnnotations = (.pi * 2) / Double(locations.count)
                for index in 0..<locations.count {
                    let location = locations[index]
                    if let latitude = location.latitude, let longitude = location.longitude {
                        let bearing = radiansBetweenAnnotations * Double(index)
                        let newCoordenates = LocationUtils.calculateCoordinateFromCoordinate(Location(latitude: latitude,
                                                                                                      longitude: longitude),
                                                                                             onBearingInRadians: bearing,
                                                                                             atDistanceInMetres: distanceFromContestedLocation)
                        let newLocation = CardMovementLocationDTO(locationRepresentable: location, latitude: newCoordenates.latitude, longitude: newCoordenates.longitude)
                        output.append(newLocation)
                    }
                }
            } else {
                output.append(locations[0])
            }
        }
        return output
    }
}
