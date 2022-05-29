//
//  Banner.swift
//  Models
//
//  Created by alvola on 29/04/2020.
//

public struct Banner {
    let bannerDTO: BannerDTO
    
    static func createFromDTO(_ dto: BannerDTO?) -> Banner? {
        guard let dto = dto  else { return nil }
        return Banner(dto: dto)
    }
    
    private init(dto: BannerDTO) {
        bannerDTO = dto
    }
    
    var app: String? {
        return bannerDTO.app
    }
    
    var height: Float? {
        return Float(bannerDTO.height)
    }
    
    var width: Float? {
        return bannerDTO.width
    }
    
    var url: String? {
        return bannerDTO.url
    }
}
