//
//  CardBlockReasonViewModel.swift
//  Cards
//
//  Created by Iván Estévez Nieto on 16/6/21.
//

import Foundation

final class CardBlockReasonViewModel {
    let imageUrl: String
    let title: String
    let subtitle: String
    
    init(imageUrl: String, title: String, subtitle: String) {
        self.imageUrl = imageUrl
        self.title = title
        self.subtitle = subtitle
    }
}
