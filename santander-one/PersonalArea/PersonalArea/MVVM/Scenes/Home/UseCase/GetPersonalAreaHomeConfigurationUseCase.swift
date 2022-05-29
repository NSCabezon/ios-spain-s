//
//  GetPersonalAreaHomeConfigurationUseCase.swift
//  PersonalArea
//
//  Created by alvola on 5/4/22.
//

import Foundation
import OpenCombine

public protocol GetPersonalAreaHomeConfigurationUseCase {
    func fetchPersonalAreaHomeConfiguration() -> AnyPublisher<PersonalAreaHomeRepresentable, Never>
}
