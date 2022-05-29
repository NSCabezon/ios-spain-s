import Fuzi
public class GetMifidIndicatorParser: BSANParser<GetMifidIndicatorResponse, GetMifidIndicatorHandler> {
    override func setResponseData() {
        response.mifidIndicatorDTO = handler.mifidIndicatorDTO
    }
}

public class GetMifidIndicatorHandler: BSANHandler {
    var mifidIndicatorDTO = MifidIndicatorDTO()
    
    override func parseElement(element: XMLElement) throws {
        guard let tag = element.tag else { return }
        switch tag {
        case "evaluados":
            var evaluatedList = [MifidEvaluatedDTO]()
            for evaluado in element.children {
                var evaluated = MifidEvaluatedDTO()
                if let persona = evaluado.firstChild(css: "persona"){
                    evaluated.client = ClientDTOParser.parse(persona)
                }
                if let indClasFirma = evaluado.firstChild(css: "indClasFirma") {
                    evaluated.indClasFirma = DTOParser.safeBoolean(indClasFirma.stringValue)
                }
                
                if let listaTest = evaluado.firstChild(css: "listaTest") {
                    var testList = [MifidTestIndicatorDTO]()
                    
                    for test in listaTest.children {
                        var prueba = MifidTestIndicatorDTO()
                        if let testId = test.firstChild(css: "idTest") {
                            prueba.testId = testId.stringValue.trim()
                        }
                        
                        if let indVigencia = test.firstChild(css: "indVigencia"){
                            prueba.indVigencia = DTOParser.safeBoolean(indVigencia.stringValue.trim())
                        }
                        
                        if let fechaAlta = test.firstChild(css: "fechaAlta"){
                            prueba.startDate = DateFormats.safeDate(fechaAlta.stringValue)
                        }
                        
                        if let fechaFin = test.firstChild(css: "fechaFin"){
                            prueba.endDate = DateFormats.safeDate(fechaFin.stringValue)
                        }
                        
                        if let gdId = test.firstChild(css: "gdId"){
                            prueba.gdId = gdId.stringValue.trim()
                        }
                        
                        if let tipoDocumental = test.firstChild(css: "tipoDocumental"){
                            prueba.tipoDocumental = tipoDocumental.stringValue.trim()
                        }
                        
                        if let tipoDocumentalDigi = test.firstChild(css: "tipoDocumentalDigi"){
                            prueba.tipoDocumentalDigi = tipoDocumentalDigi.stringValue.trim()
                        }
                        
                        if let numContrato = test.firstChild(css: "numContrato"){
                            prueba.contract = ContractDTOParser.parse(numContrato)
                        }
                        
                        if let estadoTest = test.firstChild(css: "estadoTest"){
                            var testStatus = MifidTestStatusDTO()
                            
                            let dictionary = getGtdTipo(node: estadoTest)
                            testStatus.company = dictionary["EMPRESA"]
                            testStatus.alphanumericalCod = dictionary["COD_ALFANUM_5"]
                            
                            if let codEstado = estadoTest.firstChild(css: "COD_ESTADO_TEST"){
                                testStatus.testStatusCod = codEstado.stringValue.trim()
                            }
                            
                            prueba.testStatus = testStatus
                        }
                        
                        if let cuestionario = test.firstChild(css: "cuestionario"){
                            var questionnaire = MifidQuestionnaireIndicatorDTO()
                            
                            if let gtdSubtipo = cuestionario.firstChild(css: "GTD_SUBTIPO_CUESTIONARIO"){
                                if let codSubtipo = gtdSubtipo.firstChild(css: "COD_SUBTIPO_CUESTIONARIO"){
                                    questionnaire.subTypeQuestionnaire = codSubtipo.stringValue.trim()
                                }
                                
                                let dictionary = getGtdTipo(node: gtdSubtipo)
                                questionnaire.company = dictionary["EMPRESA"]
                                questionnaire.alphanumericalCod = dictionary["COD_ALFANUM_5"]
                            }
                            
                            if let codCuestionario = cuestionario.firstChild(css: "COD_CUESTIONARIO") {
                                questionnaire.questionnaireCod = codCuestionario.stringValue.trim()
                            }
                            
                            prueba.mifidQuestionnaireIndicatorModel = questionnaire

                        }
                        
                        testList.append(prueba)
                    }
                    evaluated.testList = testList
                }
                evaluatedList.append(evaluated)
            }
            mifidIndicatorDTO.evaluatedList = evaluatedList
        case "info":
            fallthrough
        default:
            break
        }
    }
    
    private func getGtdTipo(node: XMLElement) -> [String : String] {
        var dictionary = [String : String]()
        if let gtdTipo = node.firstChild(css: "GTD_TIPO_CUESTIONARIO"),
            let empresa = gtdTipo.firstChild(css: "EMPRESA"),
            let codAlf5 = gtdTipo.firstChild(css: "COD_ALFANUM_5") {
            dictionary["EMPRESA"] = empresa.stringValue.trim()
            dictionary["COD_ALFANUM_5"] = codAlf5.stringValue.trim()
        }
        return dictionary
    }
}
