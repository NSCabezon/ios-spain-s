import SANLegacyLibrary

struct BlockCard {
    private(set) var blockCardDTO: BlockCardDTO
     
    private init(dto: BlockCardDTO) {
        blockCardDTO = dto
    }
    
    static func create(_ dto: BlockCardDTO) -> BlockCard {
        return BlockCard(dto: dto)
    }
    
    var signature: Signature? {
        guard let signature = blockCardDTO.signature else { return nil }
        return Signature(dto: signature)
    }
}

extension BlockCard: OperativeParameter {}
