//
//  MenuItem.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 02/09/2019.
//

import Foundation

class MenuItem {
    
    let title: String
    let logo: String
    let action: () -> Void
    
    init(title: String, logo: String, action: @escaping () -> Void) {
        self.title = title
        self.logo = logo
        self.action = action
    }
}
