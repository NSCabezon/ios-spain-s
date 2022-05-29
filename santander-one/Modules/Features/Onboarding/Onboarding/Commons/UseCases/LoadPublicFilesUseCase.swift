//
//  LoadPublicFilesUseCase.swift
//  Onboarding
//
//  Created by Jose Camallonga on 10/12/21.
//

import Foundation
import OpenCombine
import CoreFoundationLib

protocol LoadPublicFilesUseCase {
    func execute() -> AnyPublisher<Void, Error>
}

final class DefaultLoadPublicFilesUseCase {
    private let publicFilesManager: PublicFilesManagerProtocol
    private let stateSubject = PassthroughSubject<Void, Error>()
    
    init(dependencies: OnboardingLanguagesExternalDependenciesResolver) {
        publicFilesManager = dependencies.resolve()
    }
}

extension DefaultLoadPublicFilesUseCase: LoadPublicFilesUseCase {
    func execute() -> AnyPublisher<Void, Error> {
        publicFilesManager.loadPublicFiles(addingSubscriptor: DefaultLoadPublicFilesUseCase.self,
                                           withStrategy: .reload,
                                           timeout: 5,
                                           subscriptorActionBlock: { [weak self] in
            self?.stateSubject.send(())
        })
        return stateSubject.eraseToAnyPublisher()
    }
}
