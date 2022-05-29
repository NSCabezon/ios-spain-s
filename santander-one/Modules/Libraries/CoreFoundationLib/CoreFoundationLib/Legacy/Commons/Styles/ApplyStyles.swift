//
//  ApplyStyles.swift
//  RetailLegacy
//
//  Created by Ernesto Fernandez Calles on 20/4/21.
//


public final class ApplyStyles {
    
    public static var shared: ApplyStyles = ApplyStyles()
    private var dependenciesResolver: DependenciesResolver?
    
    public func setup(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
    
    func applyStyles(to string: String) -> LocalizedStylableText {
        guard let dependenciesResolver = self.dependenciesResolver else {
            RetailLogger.e("ApplyStyles", "Please, call to ApplyStyles.shared.setup(dependenciesResolver:) method to configure")
            return LocalizedStylableText.plain(text: NSLocalizedString(string, comment: ""))
        }
        return dependenciesResolver.resolve(for: StylesLoader.self).applyStyles(to: string)
    }
    
    func applyStyles(to string: String, _ stringPlaceHolder: [StringPlaceholder]) -> LocalizedStylableText {
        guard let dependenciesResolver = self.dependenciesResolver else {
            RetailLogger.e("ApplyStyles", "Please, call to ApplyStyles.shared.setup(dependenciesResolver:) method to configure")
            return LocalizedStylableText.plain(text: NSLocalizedString(string, comment: ""))
        }
        return dependenciesResolver.resolve(for: StylesLoader.self).applyStyles(to: string, stringPlaceHolder)
    }
}

public func applyStyles(to string: String) -> LocalizedStylableText {
    return ApplyStyles.shared.applyStyles(to: string)
}

public func applyStyles(to string: String, _ stringPlaceHolder: [StringPlaceholder]) -> LocalizedStylableText {
    return ApplyStyles.shared.applyStyles(to: string, stringPlaceHolder)
}
