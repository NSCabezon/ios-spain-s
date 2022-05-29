//
//  GetManagerImageUseCase.swift
//  PrivateMenu
//
//  Created by Boris Chirino Fernandez on 6/4/22.
//

import OpenCombine
import OpenCombineFoundation
import CoreDomain
import CoreFoundationLib

public protocol GetManagerImageUseCase {
    func fetchProfileImage(_ managerId: String) -> AnyPublisher<Data, Error>
}

struct DefaultGetManagerImageUseCase {
    private let appRepository: AppRepositoryProtocol
    
    init(dependencies: PrivateMenuExternalDependenciesResolver) {
        appRepository = dependencies.resolve()
    }
}

extension DefaultGetManagerImageUseCase: GetManagerImageUseCase {
    func fetchProfileImage(_ managerId: String) -> AnyPublisher<Data, Error> {
      let publisher = profileUrlForManagerPublisher(managerId)
            .flatMap { url -> AnyPublisher<Data, Error> in
                return getFromUrl(url)
            }
        return publisher.eraseToAnyPublisher()
    }
}

private extension DefaultGetManagerImageUseCase {
    func profileUrlForManagerPublisher(_ managerId: String) -> AnyPublisher<URL, Error> {
        return appRepository.getReactivePublicFileURL()
            .map { url in
                let pathComponent = "apps/SAN/imgGP/\(managerId).jpg"
                let fullUrl = url.appendingPathComponent(pathComponent)
                return fullUrl
            }.eraseToAnyPublisher()
    }
    
    func getFromUrl(_ url: URL)  -> AnyPublisher<Data, Error> {
      return URLSession.shared.ocombine.dataTaskPublisher(for: url)
            .flatMap { data, response in
                return Just(data).eraseToAnyPublisher()
            }
            .catch { error in
                return Fail(error: error)
            }
            .compactMap {$0}
            .eraseToAnyPublisher()
    }
}
