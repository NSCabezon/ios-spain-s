import CoreFoundationLib
import RetailLegacy

final class UniversalLinkManager: UniversalLinkManagerProtocol {
    private let dependenciesResolver: DependenciesResolver
    private let drawer: BaseMenuViewController
    private var presentationDelegate: UniversalLauncherPresentationHandler?
    private var universalLink: UniversalLink?
    private let navigator: UniversalLinkNavigator
    var isNecessaryToLaunch: Bool { universalLink != nil }

    init(drawer: BaseMenuViewController, dependencies: DependenciesResolver) {
        self.drawer = drawer
        self.dependenciesResolver = dependencies
        self.navigator = UniversalLinkNavigator(drawer: drawer)
    }

    func registerUniversalLink(_ url: URL) -> Bool {
        guard let universalLink = evaluateUniversalLinkWithURL(url) else { return false }
        self.universalLink = universalLink
        self.launchWithPresentingIfNeeded()
        return true
    }

    func registerPresenting(_ presenting: UniversalLauncherPresentationHandler) {
        self.presentationDelegate = presenting
    }

    func launchWithPresentingIfNeeded() {
        guard let universalLink = self.universalLink,
              self.presentationDelegate != nil else { return }
        self.navigator.restoreDefaultViewSettings()
        UniversalLinkLauncher(dependenciesResolver: dependenciesResolver)
            .launch(universalLink)
        self.cleanAll()
    }
}

private extension UniversalLinkManager {
    func cleanAll() {
        self.universalLink = nil
    }

    func evaluateUniversalLinkWithURL(_ url: URL) -> UniversalLink? {
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let dict = convertQueryItemsToDictionary(urlComponents?.queryItems)
        guard let path = urlComponents?.path,
              let universalLink = try? UniversalLink(path, userInfo: dict) else { return nil }
        return universalLink
    }

    func convertQueryItemsToDictionary(_ queryItems: [URLQueryItem]?) -> [String: String?] {
        guard let queryItems = queryItems else { return [:] }
        return Dictionary(uniqueKeysWithValues: queryItems.compactMap { ($0.name, $0.value?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))})
    }
}
