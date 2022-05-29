//
//  LoadingLoginViewCapable.swift
//  Pods
//
//  Created by Juan Carlos López Robles on 11/27/20.
//

import Foundation
import CoreFoundationLib
import UI

protocol LoadingLoginViewCapable: LoadingViewPresentationCapable, ShakeDelegate {}

extension LoadingLoginViewCapable {
    func showLoadingText(title: LocalizedStylableText, subtitle: LocalizedStylableText) {
        self.setLoadingText(LoadingText(title: title, subtitle: subtitle))
    }
    
    func showLoadingPlaceHolders() {
        let loadingText = LoadingText(
            title: localized("login_popup_loadingPg"),
            subtitle: localized("loading_label_moment")
        )
        let placeholders = [
            Placeholder("pgPlaceholderFakeTop", 0),
            Placeholder("pgPlaceholderFakeOfert", 14),
            Placeholder("pgPlaceholderFakeProduct", 14),
            Placeholder("pgPlaceholderFakeProduct", 14)
        ]
        self.setLoadingText(loadingText)
        let topInset = 44 + Screen.statusBarHeight
        self.setPlaceholder(placeholders, topInset: topInset, background: .paleGrey)
    }
    
    func showLoadingWithInfo(completion: (() -> Void)?) {
        let loadingText = LoadingText(
            title: localized("login_popup_identifiedUser"),
            subtitle: localized("loading_label_moment")
        )
        let type = LoadingViewType.onDrawer(completion: completion, shakeDelegate: self)
        let info = LoadingInfo(type: type, loadingText: loadingText, placeholders: nil, topInset: nil)
        self.showLoadingWithLoading(info: info)
    }
}
