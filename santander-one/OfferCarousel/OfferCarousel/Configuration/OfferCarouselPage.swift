//
//  OfferCarouselPage.swift
//  GlobalPosition
//
//  Created by Rubén Márquez Fernández on 9/7/21.
//

import Foundation
import CoreFoundationLib

struct OfferCarouselPage: PageWithActionTrackable {
    typealias ActionType = Action
    let page: String
    enum Action: String {
        case viewPromotion = "view_promotion"
        case swipe
        case selectContent = "select_content"
    }
    
    init(page: String) {
        self.page = page
    }
}

