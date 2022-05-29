//
//  OnboardingRepository.swift
//  CoreDomain
//
//  Created by Jose Ignacio de Juan Díaz on 2/12/21.
//

import OpenCombine

public protocol OnboardingRepository {
    func getOnboardingInfo() -> AnyPublisher<OnboardingInfoRepresentable, Error>
}
