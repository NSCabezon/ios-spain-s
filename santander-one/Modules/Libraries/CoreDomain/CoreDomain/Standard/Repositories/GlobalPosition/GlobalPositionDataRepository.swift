//
//  GlobalPositionRepository.swift
//  Account
//
//  Created by Juan Carlos López Robles on 10/29/21.
//

import Foundation
import OpenCombine

public protocol GlobalPositionDataRepository {
    func getGlobalPosition() -> AnyPublisher<GlobalPositionDataRepresentable, Never>
    func getMergedGlobalPosition() -> AnyPublisher<GlobalPositionAndUserPrefMergedRepresentable, Never>
}
