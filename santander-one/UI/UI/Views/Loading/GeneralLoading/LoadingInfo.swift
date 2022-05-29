//
//  LoadingInfo.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 19/11/2020.
//

import Foundation

public struct LoadingInfo {
    let type: LoadingViewType
    let loadingText: LoadingText?
    let placeholders: [Placeholder]?
    let topInset: Double?
    let background: UIColor?
    let loadingImageType: LoadingImageType
    let style: LoadingStyle
    let gradientViewStyle: LoadingGradientViewStyle
    let spacingType: LoadingSpacingType
    let loaderAccessibilityIdentifier: String?
    let titleAccessibilityIdentifier: String?
    let subtitleAccessibilityIdentifier: String?
    
    public init(type: LoadingViewType, loadingText: LoadingText? = nil, placeholders: [Placeholder]? = nil, topInset: Double? = nil, background: UIColor? = nil, loadingImageType: LoadingImageType = .spin, style: LoadingStyle = .global, gradientViewStyle: LoadingGradientViewStyle = .global, spacingType: LoadingSpacingType = .zero, loaderAccessibilityIdentifier: String? = nil, titleAccessibilityIdentifier: String? = nil, subtitleAccessibilityIdentifier: String? = nil) {
        self.type = type
        self.loadingText = loadingText
        self.placeholders = placeholders
        self.topInset = topInset
        self.background = background
        self.loadingImageType = loadingImageType
        self.style = style
        self.gradientViewStyle = gradientViewStyle
        self.spacingType = spacingType
        self.loaderAccessibilityIdentifier = loaderAccessibilityIdentifier
        self.titleAccessibilityIdentifier = titleAccessibilityIdentifier
        self.subtitleAccessibilityIdentifier = subtitleAccessibilityIdentifier
    }
}
