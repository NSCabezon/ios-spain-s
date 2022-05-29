//
//  LoadingTipsListDTO.swift
//  Models
//
//  Created by Luis Escámez Sánchez on 03/02/2020.
//

public struct LoadingTipsListDTO: Codable {
    public let loadingTips: [LoadingTipDTO]?

    public init(loadingTips: [LoadingTipDTO]?) {
        self.loadingTips = loadingTips
    }
}
