//
//  OperativeOnShortcutsKeywordsEntity.swift
//  Models
//
//  Created by Ignacio González Miró on 4/10/21.
//

import Foundation

public struct OperativeOnShortcutsKeywordsEntity {
    private let dto: OperativeOnShortcutsKeywordsDTO
    public var title: String { dto.title }
    public var keywords: [String] { dto.keyWords }

    public init(_ dto: OperativeOnShortcutsKeywordsDTO) {
        self.dto = dto
    }
}
