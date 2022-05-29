import SANServicesLibrary

extension AccountTransactionsListDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        self.init()
        let listContainer: XMLDecoder? = decoder.decode(key: "listadoMovimientos")
        let newContractDecoder: XMLDecoder? = decoder.decode(key: "contratoNuevo")
        guard let pagination = PaginationDTO(decoder: decoder),
              let newContractDecoder = newContractDecoder,
              let contract: ContractDTO = ContractDTO(decoder: newContractDecoder),
              let productSubtypeCode: String = decoder.decode(key: "codProducto"),
              let list: [XMLDecoder] = listContainer?.decode(key: "listadoMovimientos")
        else { return nil }
        let transfers: [AccountTransactionDTO] = list.flatMap(AccountTransactionDTO.init)
        var filledTransactions: [AccountTransactionDTO] = []
        for var transfer in transfers {
            transfer.newContract = contract
            transfer.productSubtypeCode = productSubtypeCode
            if transfer.operationDate != nil {
                filledTransactions.append(transfer)
            }
        }
        self.transactionDTOs = []
        self.pagination = pagination
    }
}
