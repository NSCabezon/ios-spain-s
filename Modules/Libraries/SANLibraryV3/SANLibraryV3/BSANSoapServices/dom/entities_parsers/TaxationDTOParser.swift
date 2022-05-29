import Foundation
import Fuzi

class TaxationDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> TaxationDTO {
        var taxationDTO = TaxationDTO()
        
        for element in node.children {
            if let tag = element.tag {
                switch tag {
                case "interesesUltimaLiquidacionBruto":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.interestsLastGrossLiquidation = decimal
                    }
                    break;
                case "interesesUltimaLiquidacionRetencionInt":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.cashbackLastSettlementRetentionInt = decimal
                    }
                case "interesesUltimaLiquidacionRetencionPorc":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.cashbackLastSettlementRetentionPorc = decimal
                    }
                    
                case "interesesUltimaLiquidacionInteresHaber":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.interestLastLiquidationInterest = decimal
                    }
                case "interesesAnualBruto":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.annualGrossInterest = decimal
                    }
                case "interesesAnualRetencion":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.annualInterestRetention = decimal
                    }
                case "interesesAnualNeto":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.annualInterestNet = decimal
                    }
                case "interesesAnualIngresosNeto":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.annualInterestIncomeNext = decimal
                    }
                case "interesesAnualTotal":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.annualInterestTotal = decimal
                    }
                case "CashbackUltimaLiquidacionBruto":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.cashbackUltimateLiquidationGross = decimal
                    }
                case "CashbackUltimaLiquidacionRetencionInt":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.cashbackLastSettlementRetentionInt = decimal
                    }
                case "CashbackUltimaLiquidacionRetencionPorc":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.cashbackLastSettlementRetentionPorc = decimal
                    }
                case "CashbackAnualBruto":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.cashbackAnnualGross = decimal
                    }
                case "CashbackAnualRetencion":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.cashbackAnnualRetention = decimal
                    }
                case "CashbackAnualNeto":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.cashbackAnnualNet = decimal
                    }
                case "accionesUltimaLiquidacionValorMercado":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.actionsLastValidationValueMarket = decimal
                    }
                case "accionesUltimaLiquidacionIngreso":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.actionsLiquidationIncome = decimal
                    }
                case "accionesUltimaLiquidacionRetencionPorc":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.actionsLiquitationRetention = decimal
                    }
                case "accionesAnualValorMercado":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.annualStockMarket = decimal
                    }
                case "accionesAnualIngreso":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.annualIncomeActions = decimal
                    }
                case "accionesAnualAcciones":
                    if let decimal = safeDecimal(element.stringValue) {
                        taxationDTO.annualActions = decimal
                    }
                default:
                    BSANLogger.e("TaxationDTOParser", "Nodo Sin Parsear! -> \(tag)")
                    break
                }
            }
        }
        return taxationDTO
    }
}
