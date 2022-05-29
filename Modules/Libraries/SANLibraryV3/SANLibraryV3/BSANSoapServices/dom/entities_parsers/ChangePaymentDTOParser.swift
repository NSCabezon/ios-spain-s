import Foundation
import Fuzi

class ChangePaymentDTOParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> ChangePaymentDTO {
        var changePaymentDTO = ChangePaymentDTO()
        
        if let formaDePagoActual = node.firstChild(tag: "formaDePagoActual") {
            changePaymentDTO.currentPaymentMethod = PaymentMethodType(rawValue: formaDePagoActual.stringValue.trim())
        }
        
        if let descFormPagoActual = node.firstChild(tag: "descFormPagoActual") {
            changePaymentDTO.currentPaymentMethodDescription = descFormPagoActual.stringValue.trim()
        }
        if let lista = node.firstChild(tag: "lista") {
            var paymentMethodList: [PaymentMethodDTO] = []
            for dato in lista.children {
                paymentMethodList.append(PaymentMethodDTOParser.parse(dato))
            }
            changePaymentDTO.paymentMethodList = paymentMethodList
        }
        
        if let tipoLiquidacionActual = node.firstChild(tag: "tipoLiquidacionActual") {
            changePaymentDTO.currentSettlementType = tipoLiquidacionActual.stringValue.trim()
        }
        
        if let codigoMercado = node.firstChild(tag: "codigoMercado") {
            changePaymentDTO.marketCode = codigoMercado.stringValue.trim()
        }
        
        if let modalidadFormaPagoActual = node.firstChild(tag: "modalidadFormaPagoActual") {
            changePaymentDTO.currentPaymentMethodMode = modalidadFormaPagoActual.stringValue.trim()
        }
        
        if let estandarDeReferencia = node.firstChild(tag: "estandarDeReferencia") {
            changePaymentDTO.referenceStandard = ReferenceStandardDTOParser.parse(estandarDeReferencia)
        }
        
        if let modalidadFormaPagoOculto = node.firstChild(tag: "modalidadFormaPagoOculto") {
            changePaymentDTO.hiddenPaymentMethodMode = modalidadFormaPagoOculto.stringValue.trim()
        }
        
        if let estandarReferenciaOculto = node.firstChild(tag: "estandarReferenciaOculto") {
            changePaymentDTO.hiddenReferenceStandard = ReferenceStandardDTOParser.parse(estandarReferenciaOculto)
        }
        
        if let codigoMercadoOculto = node.firstChild(tag: "codigoMercadoOculto") {
            changePaymentDTO.hiddenMarketCode = codigoMercadoOculto.stringValue.trim()
        }
        //Ñapa obligatoria.
        if changePaymentDTO.currentPaymentMethod == .deferredPayment, var paymentMethodList = changePaymentDTO.paymentMethodList, let currentPaymentMethodDescription = changePaymentDTO.currentPaymentMethodDescription {
            var previousPercentageAmount: Double?
            let splittedText = currentPaymentMethodDescription.split(" ")
            for i in 1..<splittedText.count {
                if splittedText[i].contains("%") {
                    previousPercentageAmount = Double(splittedText[i-1].replace(",",".")) 
                    break
                }
            }
            for i in 0..<paymentMethodList.count {
                var paymentMethod = paymentMethodList[i]
                switch paymentMethod.paymentMethod {
                case .deferredPayment?:
                    paymentMethod.feeAmount = AmountDTO(value: Decimal(previousPercentageAmount ?? 0), currency: paymentMethod.feeAmount?.currency ?? CurrencyDTO.create(CurrencyType.other("")))
                case .fixedFee?:
                    paymentMethod.feeAmount = AmountDTO(value: 0, currency: paymentMethod.feeAmount?.currency ?? CurrencyDTO.create(CurrencyType.other("")))
                default:
                    break
                }
                paymentMethodList[i] = paymentMethod
            }
            changePaymentDTO.paymentMethodList = paymentMethodList
        }
        return changePaymentDTO
    }
}
