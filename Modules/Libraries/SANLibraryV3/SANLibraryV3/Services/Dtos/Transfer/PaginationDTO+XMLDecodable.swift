import SANServicesLibrary

extension PaginationDTO: XMLDecodable {
    public init?(decoder: XMLDecoder) {
        self.init()
        if let finLista: Bool? = decoder.decode(key: "finLista") {
            self.endList = finLista == true
        }
        if let finListado: Bool? = decoder.decode(key: "finListado") {
            self.endList = finListado == true
        }
        if let importeCta: XMLDecoder? = decoder.decode(key: "importeCta"),
           let xmlString = importeCta?.xml() {
            self.accountAmountXML = xmlString.trim()
        }
        if let repo: XMLDecoder? = decoder.decode(key: "repo"),
           let xmlString = repo?.xml() {
            self.repositionXML = xmlString.trim()
        }
        if let repos: XMLDecoder? = decoder.decode(key: "repos"),
           let xmlString = repos?.xml() {
            self.repositionXML = xmlString.trim()
        }
        if let reposicionamiento: XMLDecoder? = decoder.decode(key: "reposicionamiento"),
           let xmlString = reposicionamiento?.xml() {
            self.repositionXML = xmlString.trim().replace("reposicionamiento", "repos")
            let stringIndicator: String? = reposicionamiento?.decode(key: "indMasDatMisPag")
            self.endList = stringIndicator == "N"
        }
        if let datosPaginacion: XMLDecoder? = decoder.decode(key: "datosPaginacion"),
           let xmlString = datosPaginacion?.xml() {
            let paginationTemp = xmlString.trim()
            self.repositionXML = paginationTemp.replace("datosPaginacion", "paginacion")
        }
        if let paginacion: XMLDecoder? = decoder.decode(key: "paginacion"),
           let xmlString = paginacion?.xml() {
            self.repositionXML = xmlString.trim()
        }
    }
}
