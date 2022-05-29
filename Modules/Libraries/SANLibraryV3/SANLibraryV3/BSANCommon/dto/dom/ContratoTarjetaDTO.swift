public struct ContratoTarjetaDTO: Codable {
    public var centro = CentroDTO()
    public var producto: String = ""
    public var numeroContrato: String = ""
}
