//
//  FontsHandler.swift
//  CoreFoundationLib
//
//  Created by Fernando Sánchez García on 16/3/22.
//

import Foundation

public class FontsHandler {
    public static let shared = FontsHandler()
    private static var dependenciesResolver: DependenciesResolver?
    
    public class func setup(dependenciesResolver: DependenciesResolver) {
        FontsHandler.dependenciesResolver = dependenciesResolver
    }

    public func santander(family: FontFamily = FontFamily.text, type: FontType = .regular, size: CGFloat) -> UIFont {
        let fontFamilyAssigned = fontFamilyDescriptionFor(family: family)
        let fontTypeAssigned = fontFamilyTypeFor(family: family, type: type)
        return UIFont(name: "\(fontFamilyAssigned)-\(fontTypeAssigned.description)", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    private func fontFamilyDescriptionFor(family: FontFamily) -> String {
        let languageGroup = getLanguageGroup()
        if languageGroup == .cyrillic {
            return FontFamily.openSans.description
        } else {
            return family.description
        }
    }
    
    private func fontFamilyTypeFor(family: FontFamily, type: FontType) -> String {
        let languageGroup = getLanguageGroup()
        if languageGroup == .cyrillic && family == .lato {
            return type.cyrillicLatoDescription
        } else {
            return type.description
        }
    }

    private func getLanguageGroup() -> LanguageGroup {
        guard let resolver = FontsHandler.dependenciesResolver else { return .latin }
        return resolver.resolve(forOptionalType: StringLoader.self)?.getCurrentLanguage().languageType.languageGroup  ?? .latin
    }
}
