//
//  FavouriteCarouselConstants.swift
//  Commons
//
//  Created by Ignacio González Miró on 29/09/2020.
//

import Foundation

public struct FavouriteCarouselPage: PageWithActionTrackable {
    public typealias ActionType = Action
    
    public let page = "favoritos_pg"
    
    public enum Action: String {
        case favouriteSelected = "seleccionar_favorito"
    }
    public init() {}
}
