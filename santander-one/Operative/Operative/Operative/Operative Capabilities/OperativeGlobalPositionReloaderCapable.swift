import CoreFoundationLib

public protocol OperativeGlobalPositionReloaderCapable {
    var dependenciesResolver: DependenciesResolver { get }
    func reloadGlobalPosition()
}

public extension OperativeGlobalPositionReloaderCapable {
    func reloadGlobalPosition() {
        self.dependenciesResolver.resolve(for: GlobalPositionReloader.self).reloadGlobalPosition()
    }
}
