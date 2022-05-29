import SANServicesLibrary

extension AccountTransactionDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        self.init()
        self.operationDate = decoder.decode(key: "fechaOperacion", format: DateFormats.TimeFormat.YYYYMMDD.rawValue)
        self.valueDate = decoder.decode(key: "fechaValor", format: DateFormats.TimeFormat.YYYYMMDD.rawValue)
        self.amount = decoder.decode(key: "importe").flatMap(AmountDTO.init)
        self.transactionType = decoder.decode(key: "tipoMovimiento")
        self.balance = decoder.decode(key: "importeSaldo").flatMap(AmountDTO.init)
        self.transactionDay = decoder.decode(key: "diaMovimiento")
        self.annotationDate = decoder.decode(key: "fechaAnotacion", format: DateFormats.TimeFormat.YYYYMMDD.rawValue)
        self.dgoNumber = decoder.decode(key: "numeroDGO").flatMap(DGONumberDTO.init)
        self.description = decoder.decode(key: "descripcion")
        self.transactionNumber = decoder.decode(key: "numeroMovimiento")
        self.pdfIndicator = decoder.decode(key: "indicadorPdf")
    }
}
