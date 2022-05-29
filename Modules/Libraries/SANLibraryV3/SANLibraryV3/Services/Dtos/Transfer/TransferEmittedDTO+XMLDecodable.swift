import SANServicesLibrary

extension TransferEmittedDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        self.init()
        self.executedDate = decoder.decode(key: "fechaEjecucion", format: DateFormats.TimeFormat.YYYYMMDD.rawValue)
        self.beneficiary = decoder.decode(key: "nombreBeneficiario")
        self.concept = decoder.decode(key: "concepto")
        self.amount = decoder.decode(key: "importe").flatMap(AmountDTO.init)
        self.countryCode = decoder.decode(key: "pais")
        self.serviceOrder = decoder.decode(key: "ordenServicio").flatMap(ContractDTO.init)
        self.transferNumber = decoder.decode(key: "numeroTransferencia")
        self.aplicationCode = decoder.decode(key: "codigoAplicacion")
        self.transferType = decoder.decode(key: "tipoTransferencia")
        self.countryName = decoder.decode(key: "nombrePais")
    }
}
