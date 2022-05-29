//
//  GetUsernameUseCase.swift
//  PersonalArea
//
//  Created by alvola on 19/4/22.
//

import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetUsernameUseCase {
    func fetchUsernamePublisher() -> AnyPublisher<String?, Never>
}

struct DefaultGetUsernameUseCase {
    private let globalPositionRepository: GlobalPositionDataRepository
    
    init(dependencies: PersonalAreaHomeExternalDependenciesResolver) {
        self.globalPositionRepository = dependencies.resolve()
    }
}

extension DefaultGetUsernameUseCase: GetUsernameUseCase {
    func fetchUsernamePublisher() -> AnyPublisher<String?, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .map(availableUsername)
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetUsernameUseCase {
    func availableUsername(_ globalPositionData: GlobalPositionDataRepresentable) -> String? {
        guard let name = globalPositionData.clientNameWithoutSurname,
              let lastName = globalPositionData.clientFirstSurnameRepresentable,
              !name.isEmpty, !lastName.isEmpty
        else { return globalPositionData.clientName ?? "" }
        return "\(name) \(lastName)"
    }
}
