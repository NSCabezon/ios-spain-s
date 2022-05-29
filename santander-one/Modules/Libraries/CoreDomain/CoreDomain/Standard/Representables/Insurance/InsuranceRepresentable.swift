//
//  InsuranceRepresentable.swift
//  CoreFoundationLib
//
//  Created by Pedro Meira on 17/08/2021.
//

public protocol InsuranceRepresentable: GlobalPositionProductIdentifiable {
    var alias: String? { get }
    var contractRepresentable: ContractRepresentable? { get }
    var ownershipTypeDesc: OwnershipTypeDesc? { get }
    var currencyRepresentable: CurrencyRepresentable? { get }
    var fecSituacionCto: Date? { get }
    var codCestaRepresentable: InstructionStatusRepresentable? { get }
    var codFamiliaProdRepresentable: InstructionStatusRepresentable? { get }
    var indActivoPasivo: String? { get }
    var tipoOperativa: String? { get }
    var indError: Bool? { get }
    var tipoSituacionCto: String? { get }
    var importeSaldoActualRepresentable: AmountRepresentable? { get }
    var idPolizaRepresentable: InsurancePolicyRepresentable? { get }
    var cliente2Representable: ClientRepresentable? { get }
    var clienteRepresentable: ClientRepresentable? { get }
    var referenciaExterna: String? { get }
    var descIdPoliza: String? { get }
    var fechaEfecto: Date? { get }
    var codigoFamSgu: String? { get }
    var subCodFamSgu: String? { get }
    var ownershipType: String? { get }
    var productSubtypeRepresentable: ProductSubtypeRepresentable? { get }
    var contractDescription: String? { get }
    var indVisibleAlias : Bool? { get }
}

extension InsuranceRepresentable {
    public var appIdentifier: String {
        return contractRepresentable?.formattedValue ?? ""
    }
    
    public var boxType: UserPrefBoxType {
        return .insuranceSaving
    }
}
