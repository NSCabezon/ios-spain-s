//
//  MockGlobalPositionDataRepository.swift
//  CoreTestData
//
//  Created by Juan Carlos López Robles on 3/30/22.
//

import Foundation
import CoreDomain
import OpenCombine
import SANLegacyLibrary

public struct MockGlobalPositionDataRepository: GlobalPositionDataRepository {
    let globalPosition: GlobalPositionDTO
    
    public init(_ globalPosition: GlobalPositionDTO) {
        self.globalPosition = globalPosition
    }
    
    public func getGlobalPosition() -> AnyPublisher<GlobalPositionDataRepresentable, Never> {
        Just(globalPosition)
            .eraseToAnyPublisher()
    }

    public func getMergedGlobalPosition() -> AnyPublisher<GlobalPositionAndUserPrefMergedRepresentable, Never> {
        fatalError()
    }
}
