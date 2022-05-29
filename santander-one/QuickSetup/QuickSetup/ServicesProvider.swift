import CoreFoundationLib

/// A service provider is an entity that is able to provide services responses for an Example App.
public protocol ServicesProvider {
    /// This method should register the necessary protocols for enabling service responses.
    /// The protocols required are BSANManagersProvider, GlobalPositionRepresentable and GlobalPositionWithUserPrefsRepresentable
    ///
    /// - Parameter dependenciesInjector: dependencies used in the ViewController of the Example App.
    func registerDependencies(in dependencies: DependenciesInjector & DependenciesResolver)
}
