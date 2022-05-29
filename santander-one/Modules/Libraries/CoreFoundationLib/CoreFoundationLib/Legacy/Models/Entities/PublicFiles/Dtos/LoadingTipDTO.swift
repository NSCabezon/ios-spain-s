//
//  LoadingTipDTO.swift
//  Models
//
//  Created by Luis Escámez Sánchez on 03/02/2020.
//

import Foundation

public struct LoadingTipDTO: Codable {
    public let mainTitle: String?
    public let title: String?
    public let boldTitle: String?
    public let subtitle: String?

    public init(mainTitle: String?, title: String?, boldTitle: String?, subtitle: String?) {
        self.mainTitle = mainTitle?.trim()
        self.title = title?.trim()
        self.boldTitle = boldTitle?.trim()
        self.subtitle = subtitle?.trim()
    }
}
