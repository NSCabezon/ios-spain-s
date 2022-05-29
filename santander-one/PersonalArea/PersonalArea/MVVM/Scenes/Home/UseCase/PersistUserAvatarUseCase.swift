//
//  PersistUserAvatarUseCase.swift
//  PersonalArea
//
//  Created by alvola on 11/4/22.
//

import Foundation
import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol PersistUserAvatarUseCase {
    func persistUserAvatar(_ data: Data) -> AnyPublisher<Bool, Never>
}

struct DefaultPersistUserAvatarUseCase {
    private let globalPositionRepository: GlobalPositionDataRepository
    private let appRepository: AppRepositoryProtocol
    
    init(dependencies: PersonalAreaHomeExternalDependenciesResolver) {
        self.globalPositionRepository = dependencies.resolve()
        self.appRepository = dependencies.resolve()
    }
}

extension DefaultPersistUserAvatarUseCase: PersistUserAvatarUseCase {
    func persistUserAvatar(_ data: Data) -> AnyPublisher<Bool, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .flatMap { globalPosition in
                persistUserAvatarWithGlobalPosition(globalPosition,
                                                    avatarData: data)
            }
            .eraseToAnyPublisher()
    }
}

private extension DefaultPersistUserAvatarUseCase {
    func persistUserAvatarWithGlobalPosition(_ globalPositionData: GlobalPositionDataRepresentable, avatarData: Data) -> AnyPublisher<Bool, Never> {
        guard let userId = globalPositionData.userId else { return Just(false).eraseToAnyPublisher() }
        return appRepository.setReactivePersistedUserAvatar(userId: userId, data: avatarData)
    }
}
