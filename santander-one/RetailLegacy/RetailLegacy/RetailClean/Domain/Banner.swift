import Foundation
import CoreFoundationLib

struct Banner {
    let bannerDTO: BannerDTO
    
    static func createFromDTO(_ dto: BannerDTO?) -> Banner? {
        if let dto = dto {
            return Banner(dto: dto)
        }
        return nil
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
