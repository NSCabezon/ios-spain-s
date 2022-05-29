//
//  GetAvatarImageUseCase.swift
//  PrivateMenu
//
//  Created by Daniel Gómez Barroso on 4/4/22.
//

import OpenCombine
import CoreDomain
import CoreFoundationLib

public protocol GetAvatarImageUseCase {
    func fetchAvatarImage() -> AnyPublisher<Data?, Never>
}

struct DefaultGetAvatarImageUseCase {
    private let appRepository: AppRepositoryProtocol
    private let globalPositionRepository: GlobalPositionDataRepository
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        appRepository = dependencies.resolve()
        globalPositionRepository = dependencies.resolve()
    }
}

extension DefaultGetAvatarImageUseCase: GetAvatarImageUseCase {
    func fetchAvatarImage() -> AnyPublisher<Data?, Never> {
        return globalPositionRepository
            .getGlobalPosition()
            .compactMap (\.userId)
            .flatMap({ userId -> AnyPublisher<Data?, Never> in
                return appRepository.getReactivePersistedUserAvatar(userId: userId)
            })
            .eraseToAnyPublisher()
    }
}
