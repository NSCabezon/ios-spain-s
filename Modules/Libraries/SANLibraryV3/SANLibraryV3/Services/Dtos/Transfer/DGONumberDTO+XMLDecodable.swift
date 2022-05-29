import SANServicesLibrary

extension DGONumberDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        self.init()
        let bankNode: XMLDecoder? = decoder.decode(key: "CENTRO")
        self.company = bankNode?.decode(key: "EMPRESA")
        self.center = bankNode?.decode(key: "CENTRO")
        self.terminalCode = decoder.decode(key: "CODIGO_TERMINAL_DGO")
        self.number = decoder.decode(key: "NUMERO_DGO")
    }
}
