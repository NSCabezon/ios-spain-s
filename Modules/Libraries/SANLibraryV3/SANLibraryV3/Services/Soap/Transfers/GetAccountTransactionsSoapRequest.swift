import SANServicesLibrary
import CoreDomain
import Foundation

struct GetAccountTransactionsSoapRequest: SoapBodyConvertible {
    let filter: AccountTransferFilterInput?
    let contract: ContractRepresentable
    let pagination: PaginationDTO?
    
    var body: String {
        var dateFilter = ""
        if let fromDate = filter?.dateFilter.fromDateModel {
            dateFilter += """
            <fechaDesde>
                <dia>\(fromDate.day)</dia>
                <mes>\(fromDate.month)</mes>
                <anyo>\(fromDate.year)</anyo>
            </fechaDesde>"
        """
        }
        if let toDate = filter?.dateFilter.toDateModel {
            dateFilter += """
            <fechaDesde>
                <dia>\(toDate.day)</dia>
                <mes>\(toDate.month)</mes>
                <anyo>\(toDate.year)</anyo>
            </fechaDesde>"
        """
        }
        return """
            <importeDesde>\(AmountFormats.getValueForWS(value: filter?.startAmount?.value))</importeDesde>
            <importeHasta>\(AmountFormats.getValueForWS(value: filter?.endAmount?.value))</importeHasta>
            <contratoID>
                <CENTRO>
                    <EMPRESA>\(contract.bankCode ?? "")</EMPRESA>
                    <CENTRO>\(contract.branchCode ?? "")</CENTRO>
                </CENTRO>
                <PRODUCTO>\(contract.product ?? "")</PRODUCTO>
                <NUMERO_DE_CONTRATO>\(contract.contractNumber ?? "")</NUMERO_DE_CONTRATO>
            </contratoID>
            \(pagination?.accountAmountXML ?? "")
            <esUnaPaginacion>\(pagination != nil ? "S" : "N")</esUnaPaginacion>
            <conceptoConsAv>\(filter?.transferType.code ?? "")</conceptoConsAv>
            <tipoOrdenacion>D</tipoOrdenacion>
            <tipoMovimiento>\(filter?.movementType.code ?? "")</tipoMovimiento>
            \(pagination?.repositionXML ?? "")
        \(dateFilter)
        """
    }
}
