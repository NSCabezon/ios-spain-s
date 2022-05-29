//
//  PersonalAreaRepository.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 4/2/22.
//

import OpenCombine

public protocol PersonalAreaRepository {
    func fetchDigitalProfilePercentage() -> AnyPublisher<DigitalProfilePercentageRepresentable, Error>
    func fetchCompleteDigitalProfileInfo() -> AnyPublisher<DigitalProfileRepresentable?, Never>
}
