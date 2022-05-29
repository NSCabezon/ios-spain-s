//
//  PregrantedConfiguration.swift
//  GlobalPosition
//
//  Created by Rubén Márquez Fernández on 1/7/21.
//

import Foundation

public struct PregrantedConfiguration {
    public let isVisible: Bool
    public let isPGTopPregrantedBannerEnable: Bool
    public let pregrantedBannerColor: PregrantedBannerColor
    public let pregrantedBannerText: String
    public let pgTopPregrantedBannerStartedText: String
    
    public init(isVisible: Bool,
                isPGTopPregrantedBannerEnable: Bool,
                pregrantedBannerColor: PregrantedBannerColor,
                pregrantedBannerText: String,
                pgTopPregrantedBannerStartedText: String) {
        self.isVisible = isVisible
        self.isPGTopPregrantedBannerEnable = isPGTopPregrantedBannerEnable
        self.pregrantedBannerColor = pregrantedBannerColor
        self.pregrantedBannerText = pregrantedBannerText
        self.pgTopPregrantedBannerStartedText = pgTopPregrantedBannerStartedText
    }
}
