import SANServicesLibrary

extension TransferEmittedListDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        self.init()
        let lista: XMLDecoder? = decoder.decode(key: "lista")
        guard let transferencias: [XMLDecoder] = lista?.decode(key: "transferencia"),
              let pagination = PaginationDTO(decoder: decoder)
        else { return nil }
        let transfers: [TransferEmittedDTO] = transferencias.flatMap(TransferEmittedDTO.init)
        self.transactionDTOs = transfers
        self.paginationDTO = pagination
    }
}
