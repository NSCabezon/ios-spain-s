//
//  LoadingTipViewModel.swift
//  UI
//
//  Created by Luis Escámez Sánchez on 07/02/2020.
//

import Foundation

public struct LoadingTipViewModel {
    
    let imageName: String
    let title: String
    let mainTitle: String
    let boldTitle: String
    let subtitle: String
    
    public init(imageName: String, title: String, mainTitle: String, boldTitle: String, subtitle: String) {
        self.imageName = imageName
        self.title = title
        self.mainTitle = mainTitle
        self.boldTitle = boldTitle
        self.subtitle = subtitle
    }
}
