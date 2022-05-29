import SanLibraryV3
import SwiftyJSON

class RestDemoExecutor: RestServiceExecutor {
    
    func executeCall(restRequest: RestRequest) throws -> Any? {
        
        var stringToParse = ""
        
        //HAY QUE AÑADIR LOS JSON AL TARGET CORRESPONDIENTE (PARA TESTEAR, PONER EL TARGET SanLibraryV3Tests Y AÑADIR A COPY BUNDLE RESOURCES)
        
        if let filepath = Bundle(for: RestDemoExecutor.self).path(forResource: restRequest.serviceName, ofType: "json"){
            do {
                stringToParse = try String(contentsOfFile: filepath)
            } catch {
                return nil
            }
        }
        else{
            return nil
        }
        
        //PARA LEER ARCHIVO DEMO (NO FUNCIONANDO)
        
        //        if let filepath = Bundle.main.path(forResource: restRequest.serviceName, ofType: "json") {
        //            do {
        //                jsonToParse = try String(contentsOfFile: filepath)
        //            } catch {
        //                return nil
        //            }
        //        } else {
        //            return nil
        //        }
        
        //PARA COGER UN N-SIMO HIJO EN EL JSON
        
        let answerNumber = getAnswerNumber(request: restRequest)
        
        let json = JSON.init(parseJSON: stringToParse)
        
        if json.count > answerNumber{
            if let dictionary = json.dictionary{
                if let outputJSON = dictionary["\(answerNumber)"]{
                    return outputJSON.description
                }
            }
        }
        
        return nil
    }
    
    var logTag: String {
        return String(describing: type(of: self))
    }
    
    func getAnswerNumber(request: RestRequest) -> Int{
        
        var answerNumber = 0
        
        switch request.serviceName {
        case InsuranceDataSourceImpl.INSURANCE_DATA_SERVICE_NAME:
            answerNumber = 1
            
        default:
            break
        }
        
        return answerNumber
    }
    
}

