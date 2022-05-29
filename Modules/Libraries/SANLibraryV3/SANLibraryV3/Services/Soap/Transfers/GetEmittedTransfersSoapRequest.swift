import SANServicesLibrary
import CoreDomain
import Foundation

struct GetEmittedTransfersSoapRequest: SoapBodyConvertible {
    let pagination: PaginationDTO?
    let amountFrom: AmountRepresentable?
    let amountTo: AmountRepresentable?
    let dateFilter: DateFilter?
    
    var body: String {
        var fromDateFilterString = ""
        var toDateFilterString = ""
        if let date = dateFilter?.fromDateModel?.date {
            fromDateFilterString = DateFormats.toString(
                date: date,
                output: DateFormats.TimeFormat.YYYYMMDD
            )
        }
        if let date = dateFilter?.toDateModel?.date {
            toDateFilterString = DateFormats.toString(
                date: date,
                output: DateFormats.TimeFormat.YYYYMMDD
            )
        }
        let operationType = pagination != nil ? "R" : "L"
        let pagination = pagination?.repositionXML ?? getEmptyPagination()
        let amountFrom: AmountRepresentable = amountFrom ?? AmountDTO()
        let amountTo: AmountRepresentable = amountTo ?? AmountDTO()
        return """
            <filtro>
                <importeDesde>
                    <IMPORTE>\(amountFrom.getDecimalPart())</IMPORTE>
                    <DIVISA>\(amountFrom.currencyRepresentable?.currencyName ?? "")</DIVISA>
                </importeDesde>
                <importeHasta>
                    <IMPORTE>\(amountTo.getDecimalPart())</IMPORTE>
                    <DIVISA>\(amountTo.currencyRepresentable?.currencyName ?? "")</DIVISA>
                </importeHasta>
                <fechaDesde>\(fromDateFilterString)</fechaDesde>
                <fechaHasta>\(toDateFilterString)</fechaHasta>
                <indicadorOperacion>\(operationType)</indicadorOperacion>
            </filtro>
            \(pagination)
        """
    }
    
    private func getEmptyPagination() -> String {
        return "<paginacion>" +
        "       <indRutInterTrfInt/>" +
        "            <indMasDatTrfInt/>" +
        "            <fecEjecTrfInt/>" +
        "            <impTrfInt>" +
        "               <IMPORTE/>" +
        "               <DIVISA/>" +
        "            </impTrfInt>" +
        "            <ordSerTrfInt>" +
        "               <CENTRO>" +
        "                  <EMPRESA/>" +
        "                  <CENTRO/>" +
        "               </CENTRO>" +
        "               <PRODUCTO/>" +
        "               <NUMERO_DE_ORDEN/>" +
        "            </ordSerTrfInt>" +
        "            <indRutInterPagElTrf/>" +
        "            <indMasDatPagElTrf/>" +
        "            <fecEjecPagElTrf/>" +
        "            <impPagElTrf>" +
        "               <IMPORTE/>" +
        "               <DIVISA/>" +
        "            </impPagElTrf>" +
        "            <ordSerPagElTrf>" +
        "               <CENTRO>" +
        "                  <EMPRESA/>" +
        "                  <CENTRO/>" +
        "               </CENTRO>" +
        "               <PRODUCTO/>" +
        "               <NUMERO_DE_ORDEN/>" +
        "            </ordSerPagElTrf>" +
        "            <indRutInterPagElRm/>" +
        "            <indMasDatPagElRm/>" +
        "            <fecEjecPagElRm/>" +
        "            <impPagElRm>" +
        "               <IMPORTE/>" +
        "               <DIVISA/>" +
        "            </impPagElRm>" +
        "            <ordSerPagElRm>" +
        "               <CENTRO>" +
        "                  <EMPRESA/>" +
        "                  <CENTRO/>" +
        "               </CENTRO>" +
        "               <PRODUCTO/>" +
        "               <NUMERO_DE_ORDEN/>" +
        "            </ordSerPagElRm>" +
        "            <indRutInterTrfNc/>" +
        "            <indMasDatTrfNc/>" +
        "            <fecEjecRpHTrfNc/>" +
        "            <impRpHTrfNc>" +
        "               <IMPORTE/>" +
        "               <DIVISA/>" +
        "            </impRpHTrfNc>" +
        "            <ordSerRpHTrfNc>" +
        "               <CENTRO>" +
        "                  <EMPRESA/>" +
        "                  <CENTRO/>" +
        "               </CENTRO>" +
        "               <PRODUCTO/>" +
        "               <NUMERO_DE_ORDEN/>" +
        "            </ordSerRpHTrfNc>" +
        "            <impRpITrfNc>" +
        "               <IMPORTE/>" +
        "               <DIVISA/>" +
        "            </impRpITrfNc>" +
        "            <ordSerRpITrfNc>" +
        "               <CENTRO>" +
        "                  <EMPRESA/>" +
        "                  <CENTRO/>" +
        "               </CENTRO>" +
        "               <PRODUCTO/>" +
        "               <NUMERO_DE_ORDEN/>" +
        "            </ordSerRpITrfNc>" +
        "            <adeudo>" +
        "               <EMPRESA/>" +
        "               <CENTRO/>" +
        "            </adeudo>" +
        "            <indRutInterPagTrfIntHH/>" +
        "            <indMasDatPagTrfIntHH/>" +
        "            <fecEjecPagTrfIntHH/>" +
        "            <impPagTrfIntHH>" +
        "               <IMPORTE/>" +
        "               <DIVISA/>" +
        "            </impPagTrfIntHH>" +
        "            <ordSerPagTrfIntHH>" +
        "               <CENTRO>" +
        "                  <EMPRESA/>" +
        "                  <CENTRO/>" +
        "               </CENTRO>" +
        "               <PRODUCTO/>" +
        "               <NUMERO_DE_ORDEN/>" +
        "            </ordSerPagTrfIntHH>" +
        "            <indRutInterPagTrfIntOJ/>" +
        "            <indMasDatPagTrfIntOJ/>" +
        "            <fecEjecPagTrfIntOJ/>" +
        "            <impPagTrfIntOJ>" +
        "               <IMPORTE/>" +
        "               <DIVISA/>" +
        "            </impPagTrfIntOJ>" +
        "            <referenciaRemesa/>" +
        "</paginacion>"
    }
}
