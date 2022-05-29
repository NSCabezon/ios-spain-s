import Foundation
import CoreDomain

public struct InsuranceDTO: BaseProductDTO {
	
    // - Numero de Poliza -> referenciaExterna Si no es nil, sino descIdPoliza:
    // - Descripcion        // ContractDescription
    // - Fecha Efecto      // fechaEfecto
    // - importeSaldoActual //Total AMOUNT UI

    // contratoPartenon -> contract
    // TipoInterv - > OwnershipType
    // DescTipoInterv -> OwnershipTypeDesc
    // titular -> client
    // subtipoProd -> ProductSubtype
    // descripProd -> ContractDescription
    // descripProd -> Alias
	
	public var alias: String?
	public var contract: ContractDTO?
	public var ownershipTypeDesc: OwnershipTypeDesc?
	public var currency: CurrencyDTO?
    public var fecSituacionCto: Date?
    public var codCesta: InstructionStatusDTO?
    public var codFamiliaProd: InstructionStatusDTO?
    public var indActivoPasivo: String?
    public var tipoOperativa: String?
    public var indError: Bool?
    public var tipoSituacionCto: String?
    public var importeSaldoActual: AmountDTO?
    public var idPoliza: InsurancePolicyDTO?
    public var cliente2: ClientDTO?
    public var cliente: ClientDTO?
    public var referenciaExterna: String?
    public var descIdPoliza: String?
    public var fechaEfecto: Date?
    public var codigoFamSgu: String?
    public var subCodFamSgu: String?
    public var ownershipType: String?
    public var productSubtypeDTO: ProductSubtypeDTO?
    public var contractDescription: String?
    public var indVisibleAlias : Bool?
    public var detailsUrl: String?

    public init () {}
}

extension InsuranceDTO: InsuranceRepresentable {
    public var contractRepresentable: ContractRepresentable? {
        return self.contract
    }
    public var currencyRepresentable: CurrencyRepresentable? {
        return currency
    }
    public var codCestaRepresentable: InstructionStatusRepresentable? {
        return codCesta
    }
    public var codFamiliaProdRepresentable: InstructionStatusRepresentable? {
        return codFamiliaProd
    }
    public var importeSaldoActualRepresentable: AmountRepresentable? {
        return importeSaldoActual
    }
    public var idPolizaRepresentable: InsurancePolicyRepresentable? {
        return idPoliza
    }
    public var cliente2Representable: ClientRepresentable? {
        return cliente2
    }
    public var clienteRepresentable: ClientRepresentable? {
        return cliente
    }
    public var productSubtypeRepresentable: ProductSubtypeRepresentable? {
        return productSubtypeDTO
    }
}
