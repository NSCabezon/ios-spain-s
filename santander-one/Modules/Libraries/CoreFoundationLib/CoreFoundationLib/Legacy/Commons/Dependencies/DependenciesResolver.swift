public protocol DependenciesResolver: AnyObject {
    func resolve<ServiceType>(forOptionalType type: ServiceType.Type) -> ServiceType?
    func resolve<ServiceType>(optionalWithIdentifier identifier: String, type: ServiceType.Type) -> ServiceType?
    func resolve<ServiceType>(for type: ServiceType.Type) -> ServiceType
    func resolve<ServiceType>() -> ServiceType
    func resolve<ServiceType>(for identifier: String) -> ServiceType
    func resolve<ServiceType>(for identifier: String, type: ServiceType.Type) -> ServiceType
    func resolve<ServiceType>(firstTypeOf type: ServiceType.Type) -> ServiceType
    func resolve<ServiceType>(firstOptionalTypeOf type: ServiceType.Type) -> ServiceType?
}
