
public final class Localized {
    
    public static var shared: Localized = Localized()
    private var dependenciesResolver: DependenciesResolver?
    
    public func setup(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func localized(_ key: String) -> LocalizedStylableText {
        guard let dependenciesResolver = self.dependenciesResolver else {
            RetailLogger.e("Localized", "Please, call to Localized.shared.setup(dependenciesResolver:) method to configure")
            return LocalizedStylableText.plain(text: NSLocalizedString(key, comment: ""))
        }
        return dependenciesResolver.resolve(for: StringLoader.self).getString(key)
    }
    
    func localized(_ key: String, _ stringPlaceHolder: [StringPlaceholder]) -> LocalizedStylableText {
        guard let dependenciesResolver = self.dependenciesResolver else {
            RetailLogger.e("Localized", "Please, call to Localized.shared.setup(dependenciesResolver:) method to configure")
            return LocalizedStylableText.plain(text: NSLocalizedString(key, comment: ""))
        }
        return dependenciesResolver.resolve(for: StringLoader.self).getString(key, stringPlaceHolder)
    }
}

public func localized(_ key: String) -> LocalizedStylableText {
    return Localized.shared.localized(key)
}

public func localized(_ key: String) -> String {
    let localizedStylableText: LocalizedStylableText = localized(key)
    return localizedStylableText.text
}

public func localized(_ key: String, _ stringPlaceHolder: [StringPlaceholder]) -> LocalizedStylableText {
    let localizedStylableText: LocalizedStylableText = Localized.shared.localized(key, stringPlaceHolder)
    return localizedStylableText
}
