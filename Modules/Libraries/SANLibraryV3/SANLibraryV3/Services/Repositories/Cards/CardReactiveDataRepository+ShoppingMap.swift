//
//  CardReactiveDataRepository+ShoppingMap.swift
//  Account
//
//  Created by Hernán Villamil on 16/3/22.
//

import Foundation
import CoreDomain
import OpenCombine
import OpenCombineDispatch
import SANLegacyLibrary
import CoreFoundationLib

extension CardReactiveDataRepository {
    public func loadCardTransactionLocationsList(card: CardRepresentable) -> AnyPublisher<[CardMovementLocationRepresentable], Never> {
        guard let cardDTO = card as? CardDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<[CardMovementLocationRepresentable], Never>{ promise in
            Async(queue: .global(qos: .userInitiated)) {
                let result = getCardTransactionLocationsList(card: cardDTO)
                promise(.success(result))
            }
        }.eraseToAnyPublisher()
    }
    
    public func loadCardTransactionLocationsListByDate(card: CardRepresentable, startDate: Date, endDate: Date) -> AnyPublisher<[CardMovementLocationRepresentable], Never> {
        guard let cardDTO = card as? CardDTO else {
            return Empty().eraseToAnyPublisher()
        }
        return Future<[CardMovementLocationRepresentable], Never>{ promise in
            Async(queue: .global(qos: .userInitiated)) {
                let result = getCardTransactionLocationsListByDate(card: cardDTO,
                                                                   startDate: startDate,
                                                                   endDate: endDate)
                promise(.success(result))
            }
        }.eraseToAnyPublisher()
    }
}

private extension CardReactiveDataRepository {
    func getCardTransactionLocationsList(card: CardDTO) -> [CardMovementLocationRepresentable] {
        do {
            let locationsListResponse = try cardManager.getCardTransactionLocationsList(card: card)
            return getOutput(locationsListResponse)
        } catch {
            return []
        }
    }
    
    func getCardTransactionLocationsListByDate(card: CardDTO, startDate: Date, endDate: Date) -> [CardMovementLocationRepresentable] {
        do {
            let locationsListResponse = try cardManager.getCardTransactionLocationsListByDate(card: card,
                                                                                               startDate: startDate,
                                                                                               endDate: endDate)
            return getOutput(locationsListResponse)
        } catch {
            return []
        }
    }
    
    func getOutput(_ response: BSANResponse<CardMovementLocationListDTO>) -> [CardMovementLocationRepresentable] {
        var output = [CardMovementLocationRepresentable]()
        do {
            guard response.isSuccess(), let locationsRepresentables = try response.getResponseData() else {
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
    
    func filterLocations(_ locations: [CardMovementLocationRepresentable]) -> [CardMovementLocationRepresentable] {
        let groupedLocations = groupLocations(locations)
        let output = getLocationsForOutput(groupedLocations)
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
    
    func getLocationsForOutput(_ groupedLocations: [[CardMovementLocationRepresentable]]) -> [CardMovementLocationRepresentable] {
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
                        let newLocation = CardMovementLocationDTO(locationRepresentable: location,
                                                                  latitude: newCoordenates.latitude,
                                                                  longitude: newCoordenates.longitude)
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
