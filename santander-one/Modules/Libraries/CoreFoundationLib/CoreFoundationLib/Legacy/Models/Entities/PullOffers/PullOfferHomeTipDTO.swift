//
//  HomeTipDTO.swift
//  Models
//
//  Created by César González Palomino on 29/07/2020.
//

import Foundation

public struct PullOfferHomeTipDTO: Codable {
    public var title: String?
    public var content: [PullOffersConfigTipDTO]?
}
