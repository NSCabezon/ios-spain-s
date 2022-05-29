//
//  GetUserAvatarUseCase.swift
//  PersonalArea
//
//  Created by alvola on 19/4/22.
//

import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetUserAvatarUseCase {
    func fetchUserAvatarPublisher() -> AnyPublisher<Data?, Never>
}

struct DefaultGetUserAvatarUseCase {
    private let globalPositionRepository: GlobalPositionDataRepository
    private let appRepository: AppRepositoryProtocol
    
    init(dependencies: PersonalAreaHomeExternalDependenciesResolver) {
        self.globalPositionRepository = dependencies.resolve()
        self.appRepository = dependencies.resolve()
    }
}

extension DefaultGetUserAvatarUseCase: GetUserAvatarUseCase {
    func fetchUserAvatarPublisher() -> AnyPublisher<Data?, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .flatMap(getUserAvatarWithGlobalPosition)
            .eraseToAnyPublisher()
    }
}

private extension DefaultGetUserAvatarUseCase {
    func getUserAvatarWithGlobalPosition(_ globalPositionData: GlobalPositionDataRepresentable) -> AnyPublisher<Data?, Never> {
        guard let userId = globalPositionData.userId else { return Just(nil).eraseToAnyPublisher() }
        return appRepository.getPersistedUserAvatarPublisher(userId: userId)
    }
}
