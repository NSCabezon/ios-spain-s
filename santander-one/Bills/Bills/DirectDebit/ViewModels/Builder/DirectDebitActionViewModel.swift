//
//  DirectDebitActionViewModel.swift
//  Bills
//
//  Created by Carlos Monfort Gómez on 08/04/2020.
//

import Foundation

public enum DirectDebitActionType {
    case operative
    case externalUrl(String)
}

final class DirectDebitActionViewModel {
    let title: String
    let description: String
    let imageName: String
    let type: DirectDebitActionType
    
    init(title: String, description: String, imageName: String, type: DirectDebitActionType) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.type = type
    }
}
