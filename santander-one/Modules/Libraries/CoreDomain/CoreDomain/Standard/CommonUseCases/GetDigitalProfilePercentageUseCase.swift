//
//  GetDigitalProfilePercentageUseCase.swift
//  Pods
//
//  Created by Daniel Gómez Barroso on 22/4/22.
//

import OpenCombine

public protocol GetDigitalProfilePercentageUseCase {
    func fetchDigitalProfilePercentage() -> AnyPublisher<Double, Error>
    func fetchIsDigitalProfileEnabled() -> AnyPublisher<Bool, Never>
}
