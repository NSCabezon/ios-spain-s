//
//  CoreDependencies.swift
//  CoreFoundationLib
//
//  Created by José Carlos Estela Anguita on 16/12/21.
//

import Foundation

public protocol CoreDependenciesResolver {
    func resolve() -> CoreDependencies
    func asShared<Dependency>(_ dependency: () -> Dependency) -> Dependency
}

extension CoreDependenciesResolver {
    
    public func asShared<Dependency>(_ dependency: () -> Dependency) -> Dependency {
        return resolve().asShared(dependency)
    }
}

public protocol CoreDependencies {
    func asShared<Dependency>(_ dependency: () -> Dependency) -> Dependency
}

public final class DefaultCoreDependencies: CoreDependencies {
    
    private var dependencies: [Any]
    
    public init() {
        self.dependencies = []
    }
    
    public func asShared<Dependency>(_ dependency: () -> Dependency) -> Dependency {
        guard let saved = dependencies.compactMap({ $0 as? Dependency }).first else {
            let instance = dependency()
            save(depedency: instance)
            return instance
        }
        return saved
    }
}

private extension DefaultCoreDependencies {
    
    func save<Dependency>(depedency: Dependency) {
        dependencies.append(depedency)
    }
}
