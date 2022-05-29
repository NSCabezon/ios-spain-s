import Foundation

public final class LocaleProvider {
    public static var shared: LocaleProvider = LocaleProvider()
    private var stringLoader: StringLoader?
    
    public func setup(dependenciesResolver: DependenciesResolver) {
        self.stringLoader = dependenciesResolver.resolve(for: StringLoader.self)
    }

    fileprivate var locale: Locale? {
        return stringLoader?.getCurrentLanguage().languageType.locale
    }
}

public extension Locale {
    static var appLocale: Locale {
        return LocaleProvider.shared.locale ?? .current
    }
}
