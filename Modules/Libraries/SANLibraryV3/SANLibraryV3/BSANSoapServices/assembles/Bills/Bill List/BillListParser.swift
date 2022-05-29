import Foundation
import Fuzi

public class BillListParser: BSANParser<BillListResponse, BillListHandler> {
        
    override func setResponseData() {
        response.billList = BillListDTO(bills: handler.bills, pagination: handler.pagination)
    }
}

public class BillListHandler: BSANHandler {
    
    fileprivate var bills: [BillDTO] = []
    fileprivate var pagination: PaginationDTO?
    
    override func parseResult(result: XMLElement) throws {
        let billsElement = result.firstChild(tag: "listaRecibos")
        pagination = BillListPaginationParser.parse(from: result)
        try billsElement?.children.forEach(parseElement)
    }
    
    override func parseElement(element: XMLElement) throws {
        guard let bill = try BillParser.parse(from: element) else {
            return
        }
        bills.append(bill)
    }
}

class BillParser {
    
    static func parse(from element: XMLElement) throws -> BillDTO? {
        guard
            let name = element.firstChild(tag: "nombre")?.stringValue,
            let holder = element.firstChild(tag: "titular")?.stringValue,
            let pagDate = DateFormats.safeDateInverseFull(element.firstChild(tag: "TIMEPAG")?.stringValue),
            let gauDate = DateFormats.safeDateInverseFull(element.firstChild(tag: "TIMEGAU")?.stringValue),
            let expirationDate = DateFormats.safeDate(element.firstChild(tag: "FECVENCI")?.stringValue),
            let paymentOrderCode = element.firstChild(tag: "NUMSOR")?.stringValue,
            let codProd = element.firstChild(tag: "CODPROD")?.stringValue,
            let codSubtypeProd = element.firstChild(tag: "CODSPROD")?.stringValue,
            let creditorCenterId = element.firstChild(tag: "IDCENTD")?.stringValue,
            let creditorCompanyId = element.firstChild(tag: "IDEMPR")?.stringValue,
            let imporDV = element.firstChild(tag: "IMPORDV")?.stringValue,
            let impoASOC = element.firstChild(tag: "IMPOASOC")?.stringValue,
            let creditorAccount = element.firstChild(tag: "CTAACREE")?.stringValue,
            let debtorAccount = element.firstChild(tag: "CTADEUD")?.stringValue,
            let currency = element.firstChild(tag: "CODMON")?.stringValue,
            let state = element.firstChild(tag: "CESTADO")?.stringValue,
            let idban = element.firstChild(tag: "IDBAN1")?.stringValue,
            let debtorCompanyId = element.firstChild(tag: "IDEMPRD")?.stringValue,
            let amountValue = DTOParser.safeDecimal(impoASOC),
            let code = element.firstChild(tag: "IDENTEMI")?.stringValue,
            let tipauto = element.firstChild(tag: "TIPAUTO")?.stringValue,
            let cdinaut = element.firstChild(tag: "CDINAUT")?.stringValue
        else {
            return nil
        }
        return BillDTO(
            name: name,
            holder: holder,
            state: state,
            codProd: codProd,
            codSubtypeProd: codSubtypeProd,
            paymentOrderCode: paymentOrderCode,
            creditorAccount: creditorAccount,
            creditorCenterId: creditorCenterId,
            creditorCompanyId: creditorCompanyId,
            debtorCompanyId: debtorCompanyId,
            debtorAccount: debtorAccount,
            expirationDate: expirationDate,
            idban: idban,
            gauDate: gauDate,
            pagDate: pagDate,
            imporDV: imporDV,
            company: CentroDTO(empresa: element.firstChild(tag: "IDCENT")?.firstChild(tag: "EMPRESA")?.stringValue ?? "",
                               centro: element.firstChild(tag: "IDCENT")?.firstChild(tag: "CENTRO")?.stringValue ?? ""),
            amount: AmountDTO(value: amountValue, currency: CurrencyDTO(currencyName: currency, currencyType: CurrencyType.parse(currency))),
            code: code,
            tipauto: tipauto,
            cdinaut: cdinaut
        )
    }
}


