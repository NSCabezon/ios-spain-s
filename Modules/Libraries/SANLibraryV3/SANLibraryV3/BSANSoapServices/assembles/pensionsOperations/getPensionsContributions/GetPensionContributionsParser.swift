import Fuzi

public class GetPensionContributionsParser: BSANParser<GetPensionContributionsResponse, GetPensionContributionsHandler> {
    override func setResponseData() {
        response.pensionContributionsListDTO = PensionContributionsListDTO(pensionContributions: handler.pensionContributionsDTOS, pensionInfoOperationDTO: handler.pensionInfoOperationDTO, pagination: handler.pagination)
    }
}

public class GetPensionContributionsHandler: BSANHandler {
    var pagination = PaginationDTO()
    var pensionContributionsDTOS = [PensionContributionsDTO]()
    var pensionInfoOperationDTO = PensionInfoOperationDTO()
    var pensionContributionsRepoDTO = PensionContributionsRepoDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "cuentaAsociadaAlPlanIban":
            pensionInfoOperationDTO.pensionAccountAssociated = IBANDTOParser.parse(element)
            
        case "apellidosYNombreTitular":
            pensionInfoOperationDTO.holder = element.stringValue.trim()
        case "descripcionPlanDePensiones":
            pensionInfoOperationDTO.descPension = element.stringValue.trim()
        case "tipoPlan":
            pensionInfoOperationDTO.typePlan = element.stringValue.trim()
        case "divisa":
            pensionInfoOperationDTO.currency = element.stringValue.trim()
        case "fechaAlta":
            pensionInfoOperationDTO.valueDate = DateFormats.safeDate(element.stringValue)
        case "indPorMinReval":
            pensionInfoOperationDTO.indPorMinReval = element.stringValue.trim()
        case "indRevalOblig":
            pensionInfoOperationDTO.indRevalOblig = element.stringValue.trim()
        case "numeroDeParticipe":
            pensionInfoOperationDTO.sharesNumber = DTOParser.safeDecimal(element.stringValue.trim())
        case "listaPlanAportaciones":
            for planAportacion in element.children {
                var pensionContributionsDTO = PensionContributionsDTO()
                
                if let estatusPlanAport = planAportacion.firstChild(css: "estatusPlanAport"){
                    pensionContributionsDTO.statusPlan = estatusPlanAport.stringValue.trim()
                }
                
                if let fecAltaPlanaport = planAportacion.firstChild(css: "fecAltaPlanaport"){
                    pensionContributionsDTO.highDate = DateFormats.safeDate(fecAltaPlanaport.stringValue)
                }
                
                if let tipoPlanAport = planAportacion.firstChild(css: "tipoPlanAport"){
                    pensionContributionsDTO.typePension = tipoPlanAport.stringValue.trim()
                }
                
                if let situPlanDesc = planAportacion.firstChild(css: "situPlanDesc"){
                    pensionContributionsDTO.description = situPlanDesc.stringValue.trim()
                }
                
                if let fecUltEnvExtracto = planAportacion.firstChild(css: "fecUltEnvExtracto"){
                    pensionContributionsDTO.lastUploaded = DateFormats.safeDate(fecUltEnvExtracto.stringValue)
                }
                
                if let fecSigReciEdi = planAportacion.firstChild(css: "fecSigReciEdi"){
                    pensionContributionsDTO.nextReceiptDate = DateFormats.safeDate(fecSigReciEdi.stringValue)
                }
                
                if let importeAportPlan = planAportacion.firstChild(css: "importeAportPlan"),
                    let divisaImporteAportPlan = planAportacion.firstChild(css: "divisaImporteAportPlan"){
                    
                    let amount = importeAportPlan.stringValue.trim()
                    if let value = DTOParser.safeDecimal(amount.replace(",", ".")) {
                        let currency = divisaImporteAportPlan.stringValue.trim()
                        
                        pensionContributionsDTO.contributionAmount = AmountDTO(value: value, currency: CurrencyDTO.create(currency))
                    }
                }
                
                if let numCuotasPeriodi = planAportacion.firstChild(css: "numCuotasPeriodi"){
                    pensionContributionsDTO.numberQuotaPeriodic = DTOParser.safeInteger(numCuotasPeriodi.stringValue.trim())
                }
                
                if let litPeriodi = planAportacion.firstChild(css: "litPeriodi"){
                    pensionContributionsDTO.literalPeriod = litPeriodi.stringValue.trim()
                }
                
                if let indRevalAnul = planAportacion.firstChild(css: "indRevalAnul"){
                    pensionContributionsDTO.revaluationAnnulment = indRevalAnul.stringValue.trim()
                }
                
                if let timeStampAltaTabla = planAportacion.firstChild(css: "timeStampAltaTabla"){
                    pensionContributionsDTO.timeStampTable = DateFormats.safeDateInverseFull(timeStampAltaTabla.stringValue)
                }
                
                pensionContributionsDTOS.append(pensionContributionsDTO)
            }
            
        case "repos":
            pagination.repositionXML = "<repos>"
            if let estatusPlanAport = element.firstChild(css: "estatusPlanAport"){
                pensionContributionsRepoDTO.estatusPlanAport = estatusPlanAport.stringValue.trim()
                pagination.repositionXML += "<estatusPlanAport>\(estatusPlanAport.stringValue.trim())</estatusPlanAport>"
            }
            
            if let fecAltaPlanaport = element.firstChild(css: "fecAltaPlanaport"){
                pensionContributionsRepoDTO.fecAltaPlanaport = fecAltaPlanaport.stringValue.trim()
                pagination.repositionXML += "<fecAltaPlanaport>\(fecAltaPlanaport.stringValue.trim())</fecAltaPlanaport>"
            }
            
            if let tipoPlanAport = element.firstChild(css: "tipoPlanAport"){
                pensionContributionsRepoDTO.tipoPlanAport = tipoPlanAport.stringValue.trim()
                pagination.repositionXML += "<tipoPlanAport>\(tipoPlanAport.stringValue.trim())</tipoPlanAport>"
            }
            
            if let timeStampAltaTabla = element.firstChild(css: "timeStampAltaTabla"){
                pensionContributionsRepoDTO.timeStampAltaTabla = timeStampAltaTabla.stringValue.trim()
                pagination.repositionXML += "<timeStampAltaTabla>\(timeStampAltaTabla.stringValue.trim())</timeStampAltaTabla>"
            }
            pagination.repositionXML += "</repos>"

        case "finLista":
            pagination.endList = DTOParser.safeBoolean(element.stringValue.trim())
            
        case "producto":
            pensionInfoOperationDTO.pensionProduct = ProductSubtypeDTOParser.parse(element)
            
        default:
            BSANLogger.e("GetPensionContributionsHandler", "Nodo Sin Parsear! -> \(tag)")

        }
    }
}
