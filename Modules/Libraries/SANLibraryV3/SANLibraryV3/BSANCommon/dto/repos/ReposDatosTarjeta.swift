public class ReposDatosTarjeta: ReposControl {
    public var contratoTarjeta: ContractDTO?
    public var codigoAplicacion: String = ""
    public var tipoIntervencion: String = ""
    public var numBeneficiario: String = ""
    public var numBenefTarjeta: String = ""

    public override init() {
        self.contratoTarjeta = ContractDTO()
        super.init()
    }

    required public init(from decoder: Decoder) throws {
        self.contratoTarjeta = ContractDTO()
        try super.init(from: decoder)
    }

    override public func getPaginacion() -> PaginationDTO {
		var pagination = PaginationDTO()
        pagination.repositionXML = "<repos>"
                + "         <contratoTarjeta>"
                + "             <CENTRO>"
            + "                 <EMPRESA>\(contratoTarjeta?.bankCode ?? "")</EMPRESA>"
            + "                 <CENTRO>\(contratoTarjeta?.branchCode ?? "")</CENTRO>"
                + "             </CENTRO>"
            + "             <PRODUCTO>\(contratoTarjeta?.product ?? "")</PRODUCTO>"
            + "             <NUMERO_DE_CONTRATO>\(contratoTarjeta?.contractNumber ?? "")</NUMERO_DE_CONTRATO>"
                + "         </contratoTarjeta>"
                + "         <codigoAplicacion>\(codigoAplicacion)</codigoAplicacion>"
                + "         <tipoIntervencion>\(tipoIntervencion)</tipoIntervencion>"
                + "         <numBeneficiario>\(numBeneficiario)</numBeneficiario>"
                + "         <numBenefTarjeta>\(numBenefTarjeta)</numBenefTarjeta>"
                + "         <finLista>\(pagination.endList ? "S" : "N")</finLista>"
                + "     </repos>"
        return pagination
    }

}
