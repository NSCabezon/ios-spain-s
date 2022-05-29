import Fuzi

public class GetTransactionsContractEasyPayParser: BSANParser<GetTransactionsContractEasyPayResponse, GetTransactionsContractEasyPayHandler> {
    override func setResponseData() {
        response.easyPayContractTransactionListDTO = EasyPayContractTransactionListDTO(easyPayContractTransactionDTOS: handler.easyPayContractTransactionDTOS, pagination: handler.pagination)
    }
}

public class GetTransactionsContractEasyPayHandler: BSANHandler {
    var easyPayContractTransactionDTOS = [EasyPayContractTransactionDTO]()
    var pagination = PaginationDTO()
    
    override func parseResult(result: XMLElement) throws {
        if let indFinListaMasDatos = result.firstChild(tag: "indFinListaMasDatos") {
            pagination.endList = DTOParser.safeBoolean(indFinListaMasDatos.stringValue.trim())
        }
        
        if let datosRepaginacion = result.firstChild(tag: "datosRepaginacion") {
            pagination.repositionXML = datosRepaginacion.stringValue.trim()
        }
        
        if let listaMovimientos = result.firstChild(tag: "listaMovimientos") {
            if listaMovimientos.children.count > 0 {
                for child in listaMovimientos.children {
                    var newElement = EasyPayContractTransactionDTO()
                    if let fechaMovimiento = child.firstChild(tag: "fechaMovimiento") {
                        newElement.operationDate = DateFormats.safeDate(fechaMovimiento.stringValue.trim())
                    }
                    
                    if let codOperacionBancaria = child.firstChild(tag: "codOperacionBancaria") {
                        newElement.bankOperation = codOperacionBancaria.stringValue.trim()
                    }
                    
                    if let codOperacionBasica = child.firstChild(tag: "codOperacionBasica") {
                        newElement.basicOperation = codOperacionBasica.stringValue.trim()
                    }
                    
                    if let conceptoSaldo = child.firstChild(tag: "conceptoSaldo") {
                        newElement.balanceCode = conceptoSaldo.stringValue.trim()
                    }
                    
                    if let numDeMovEnDia = child.firstChild(tag: "numDeMovEnDia") {
                        newElement.transactionDay = numDeMovEnDia.stringValue.trim()
                    }
                    
                    if let estadoPeticion = child.firstChild(tag: "estadoPeticion") {
                        newElement.requestStatus = estadoPeticion.stringValue.trim()
                    }
                    
                    if let horaMovto = child.firstChild(tag: "horaMovto") {
                        newElement.transactionTime = horaMovto.stringValue.trim()
                    }
                    
                    if let modalidadFormaPago = child.firstChild(tag: "modalidadFormaPago") {
                        newElement.paymentMethodMode = modalidadFormaPago.stringValue.trim()
                    }
                    
                    if let tiposLiquidacion = child.firstChild(tag: "tiposLiquidacion") {
                        newElement.liquidationsType = tiposLiquidacion.stringValue.trim()
                    }
                    
                    if let campoCompuesto = child.firstChild(tag: "campoCompuesto") {
                        newElement.compoundField = campoCompuesto.stringValue.trim()
                    }
                    
                    if let nombre_ApeBenefic = child.firstChild(tag: "nombre_ApeBenefic") {
                        newElement.beneficiaryApeName = nombre_ApeBenefic.stringValue.trim()
                    }
                    
                    if let nombreTarifa = child.firstChild(tag: "nombreTarifa") {
                        newElement.rateName = nombreTarifa.stringValue.trim()
                    }
                    
                    if let panMediosPago = child.firstChild(tag: "panMediosPago") {
                        newElement.paymentMethodsPan = panMediosPago.stringValue.trim()
                    }
                    
                    if let descGrupoCarc = child.firstChild(tag: "descGrupoCarc") {
                        newElement.carcGroupDesc = descGrupoCarc.stringValue.trim()
                    }
                    
                    if let fechaLiquidacion_FECLIQEX = child.firstChild(tag: "fechaLiquidacion_FECLIQEX") {
                        newElement.liquidationDate = DateFormats.safeDate(fechaLiquidacion_FECLIQEX.stringValue.trim())
                    }
                    
                    if let importeOperacionBancaria = child.firstChild(tag: "importeOperacionBancaria") {
                        newElement.amountDTO = AmountDTOParser.parse(importeOperacionBancaria)
                    }
                    
                    easyPayContractTransactionDTOS.append(newElement)
                }
            }
        }
    }
}
