//
//  GlobalAppKeywordsEntity.swift
//  Models
//
//  Created by Johnatan Zavaleta Milla on 10/06/2021.
//

import Foundation

public struct GlobalAppKeywordsEntity {
    
    private let dto: GlobalAppKeywordsDTO
    public var deepLinkIdentifier: String { dto.deepLink }
    public var icon: String { dto.icon }
    public var title: String { dto.title }
    public var keywords: [String] { dto.keyWords }

    public init(_ dto: GlobalAppKeywordsDTO) {
        self.dto = dto
    }
}
