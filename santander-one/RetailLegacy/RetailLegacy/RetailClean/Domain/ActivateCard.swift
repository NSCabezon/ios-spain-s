import SANLegacyLibrary

struct ActivateCard {
    let dto: ActivateCardDTO
    
    var signature: Signature? {
        guard let signature = dto.scaRepresentable as? SignatureDTO else { return nil }
        return Signature(dto: signature)
    }
}

extension ActivateCard: OperativeParameter {}
