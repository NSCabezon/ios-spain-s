public protocol DependenciesInjector {
    func register<ServiceType>(for type: ServiceType.Type, with factory: @escaping (DependenciesResolver) -> ServiceType)
    func register<ServiceType>(for identifier: String, type: ServiceType.Type, with factory: @escaping (DependenciesResolver) -> ServiceType)
}
