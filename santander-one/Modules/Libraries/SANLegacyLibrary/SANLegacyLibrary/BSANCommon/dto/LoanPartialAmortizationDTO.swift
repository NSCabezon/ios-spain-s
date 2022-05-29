import CoreDomain

public struct LoanPartialAmortizationDTO: Codable {
    public var loanContractDTO: ContractDTO?
    public var userContractDTO: ContractDTO?
    public var linkedAccountContractDTO: ContractDTO?
    public var linkedAccountIntContractDTO: ContractDTO?
    public var numeroSecuOper_HNUOPEM: String?
    public var codProductoContrato_IDPROD: String?
    public var codSubtipoProducto_CODSPROD: String?
    public var origenOrdenMarcajDecreto_IDORIGEN: String?
    public var indDevolEfectDEspAcept_INDACTE1: String?
    public var indDuplicado_INDDUP: String?
    public var indIntermediacion_INDINTER: String?
    public var indNoAmortizaPeriodCaren_INDNAMCA: String?
    public var indPrestamoConsu_INDPTCON: String?
    public var indPrestamoLeasing_INDPTLEA: String?
    public var indResidente_INREN: String?
    public var indGrupo_INDGRU: String?
    public var indOrigenDestino_IORIDES: String?
    public var fechaVencimiento_FECVENC2: String?
    public var fechaValor_FECVAL1: String?
    public var importeResidualLeasing_IMPDIVS4: AmountDTO?
    public var importeResidFinal_IMPDIVS5: AmountDTO?
    public var importeLimiteInicial_IMPDIVS1: AmountDTO?
    public var importeLimiteActual_IMPDIVS2: AmountDTO?
    public var nombreMoneda_NOMMONCO: String?
    public var codTecnicoAplicacion_APLICACI: String?
    public var tipoObjetoOper_ATIPOB: String?
    public var tipoObjeto_BTIPOB: String?
    public var codOperaBasica_CODOPBAS: String?
    public var campo1JerarquiaParticulari_EHIDOBJ1: String?
    public var campo2JerarquiaParticulari_EHIDOBJ2: String?
    public var codEstandarReferencia_COESTREF: String?
    public var numero: String?
    public var tipo_EHTIPOB: String?
    public var indNuevaLeyHipotecaria: String?

    public init() {}
}

extension LoanPartialAmortizationDTO: LoanPartialAmortizationRepresentable {
    public var loanContract: String? {
        loanContractDTO?.contractNumber
    }
    
    public var userContract: String? {
        userContractDTO?.contratoPK
    }
    
    public var getLinkedAccountContract: String? {
        linkedAccountContractDTO?.formattedValue
    }
    
    public var getExpiration: String? {
        fechaVencimiento_FECVENC2
    }
    
    public var getStartLimit: AmountRepresentable? {
        importeLimiteInicial_IMPDIVS1
    }
    
    public var getActualLimit: String? {
        importeLimiteActual_IMPDIVS2?.getDecimalPart(decimales: 2)
    }
    
    public var pendingAmount: AmountRepresentable? {
        importeLimiteActual_IMPDIVS2
    }
    
    public var linkedAccountIntContract: ContractRepresentable? {
        linkedAccountIntContractDTO
    }
    
    public var isNewMortgageLawLoan: Bool {
        indNuevaLeyHipotecaria?.uppercased() ?? "" == "X"
    }
}
