import SANLegacyLibrary

class RMVDetail: GenericProduct {
    
    static func create(_ from: RMVDetailDTO) -> RMVDetail {
        return RMVDetail(dto: from)
    }
    
    public let rmvDetailDTO: RMVDetailDTO
    
    private init(dto: RMVDetailDTO) {
        rmvDetailDTO = dto
        super.init()
    }
}
