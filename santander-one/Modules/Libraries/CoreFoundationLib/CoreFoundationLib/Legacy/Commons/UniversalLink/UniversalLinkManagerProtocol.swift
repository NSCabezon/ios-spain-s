import Foundation

public protocol UniversalLinkManagerProtocol {
    var isNecessaryToLaunch: Bool { get }
    func registerUniversalLink(_ url: URL) -> Bool
    func registerPresenting(_ presenting: UniversalLauncherPresentationHandler)
    func launchWithPresentingIfNeeded()
}

public protocol UniversalLauncherPresentationHandler: class {
    var dependenciesResolver: DependenciesResolver { get }
}
