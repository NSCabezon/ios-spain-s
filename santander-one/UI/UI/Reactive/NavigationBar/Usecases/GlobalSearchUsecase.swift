//
//  GlobalSearchUsecase.swift
//  Commons
//
//  Created by Juan Carlos López Robles on 12/3/21.
//

import Foundation
import OpenCombine
import CoreFoundationLib

protocol GlobalSearchUsecase {
    func fechGlobalSearch() -> AnyPublisher<Bool, Never>
}

struct DefaultGlobalSearchUsecase {
    let repository: AppConfigRepositoryProtocol
    
    init(dependencies: NavigationBarDependenciesResolver) {
        self.repository = dependencies.external.resolve()
    }
}

extension DefaultGlobalSearchUsecase: GlobalSearchUsecase {
    func fechGlobalSearch() -> AnyPublisher<Bool, Never> {
        repository.value(for: "enableGlobalSearch", defaultValue: true)
    }
}
