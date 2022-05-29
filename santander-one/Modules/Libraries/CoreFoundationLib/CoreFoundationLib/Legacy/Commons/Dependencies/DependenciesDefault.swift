public class DependenciesDefault {
    
    private typealias ResolverAlias = (DependenciesResolver) -> Any
    private var father: DependenciesResolver?
    private var resolvers: ThreadSafeProperty<[String: ResolverAlias]>
    
    public init(father: DependenciesResolver? = nil) {
        self.father = father
        self.resolvers = ThreadSafeProperty([:])
    }
    
    private func get<ServiceType>(for identifier: String) -> ServiceType? {
        guard
            let resolver: ResolverAlias = resolvers.value[identifier],
            let value: ServiceType = resolver(self) as? ServiceType
        else {
            return nil
        }
        return value
    }
    
    public func clean() {
        self.resolvers.value.removeAll()
    }
}

// MARK: - DependenciesResolver

extension DependenciesDefault: DependenciesResolver {
    
    public func resolve<ServiceType>(forOptionalType type: ServiceType.Type) -> ServiceType? {
        return self.resolve(optionalWithIdentifier: String(describing: type), type: type)
    }
    
    public func resolve<ServiceType>(optionalWithIdentifier identifier: String, type: ServiceType.Type) -> ServiceType? {
        if let value: ServiceType = get(for: identifier) {
            return value
        } else if let father: DependenciesResolver = father {
            return father.resolve(optionalWithIdentifier: identifier, type: type)
        }
        return nil
    }
    
    public func resolve<ServiceType>(for type: ServiceType.Type) -> ServiceType {
        return resolve(for: String(describing: type), type: type)
    }
    
    public func resolve<ServiceType>() -> ServiceType {
        return resolve(for: String(describing: ServiceType.self), type: ServiceType.self)
    }
    
    public func resolve<ServiceType>(for identifier: String) -> ServiceType {
        return resolve(for: identifier, type: ServiceType.self)
    }
    
    public func resolve<ServiceType>(for dependency: String, type: ServiceType.Type) -> ServiceType {
        if let value: ServiceType = get(for: dependency) {
            return value
        } else if let father: DependenciesResolver = father {
            return father.resolve(for: dependency, type: type)
        }
         fatalError("DependenciesResolver.resolve: Nothing register for \(dependency)")
    }
    
    public func resolve<ServiceType>(firstTypeOf type: ServiceType.Type) -> ServiceType {
        guard let value: ServiceType = self.resolve(firstOptionalTypeOf: type) else {
            fatalError("DependenciesResolver.resolve: Nothing register for \(String(describing: type))")
        }
        return value
    }
    
    public func resolve<ServiceType>(firstOptionalTypeOf type: ServiceType.Type) -> ServiceType? {
        if let father: DependenciesResolver = father,
           let value = father.resolve(firstOptionalTypeOf: type) {
            return value
        } else if let value: ServiceType = get(for: String(describing: type)) {
            return value
        } else {
            return nil
        }
    }
}

// MARK: - DependenciesInjector

extension DependenciesDefault: DependenciesInjector {
    public func register<ServiceType>(for type: ServiceType.Type, with factory: @escaping (DependenciesResolver) -> ServiceType) {
        let identifier: String = String(describing: type)
        self.register(for: identifier, type: type, with: factory)
    }
    
    public func register<ServiceType>(for identifier: String, type: ServiceType.Type, with factory: @escaping (DependenciesResolver) -> ServiceType) {
        resolvers.value[identifier] = factory
    }
}
