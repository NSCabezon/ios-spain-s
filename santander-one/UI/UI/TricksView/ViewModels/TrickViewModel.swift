//
//  TrickViewModel.swift
//  UI
//
//  Created by Carlos Monfort Gómez on 09/07/2020.
//

import Foundation
import CoreFoundationLib

public final class TrickViewModel {
    private let entity: TrickEntity
    private let baseUrl: String?
    
    public init(entity: TrickEntity, baseUrl: String?) {
        self.entity = entity
        self.baseUrl = baseUrl
    }

    var textButton: String {
        return entity.textButton
    }
    
    var title: String {
        return entity.title
    }
    
    var description: String {
        return self.entity.description
    }
    
    var imageUrl: String? {
        guard let baseUrl = self.baseUrl else { return nil }
        return String(format: "%@%@", baseUrl, self.entity.icon)
    }
}
