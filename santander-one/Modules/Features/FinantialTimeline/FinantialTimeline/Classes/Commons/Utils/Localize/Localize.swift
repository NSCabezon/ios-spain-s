//
//  Localize.swift
//  Cache
//
//  Created by Antonio Muñoz Nieto on 05/07/2019.
//

import Foundation

func IBLocalizedString(_ key: String, comment: String = "") -> String {
    let language = TimeLine.dependencies.configuration?.language
    guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
    let bundle = Bundle(path: path) else {
           return IBLocalizedStringFromModule(key)
    }
    
    let mainTranslation = NSLocalizedString(key, bundle: bundle, comment: comment)
    if mainTranslation != key {
        return mainTranslation
    }
    return IBLocalizedStringFromModule(key)
}

func IBLocalizedStringFromModule(_ key: String, comment: String = "") -> String {
    let language = TimeLine.dependencies.configuration?.language
    guard let modulePath = Bundle.module?.path(forResource: language, ofType: "lproj"),
    let moduleBundle = Bundle(path: modulePath) else {
            return NSLocalizedString(key, bundle: .module ?? .main, comment: comment)
    }
    return NSLocalizedString(key, bundle: moduleBundle, comment: comment)
}
