//
//  RestDemoExecutor.swift
//  SanLibraryV3Tests
//
//  Created by Carlos Pérez Pérez on 2/4/18.
//  Copyright © 2018 com.ciber. All rights reserved.
//

import SwiftyJSON
import SANLegacyLibrary

public class RestDemoExecutor: RestServiceExecutor {
    
    let demoInterpreter: DemoInterpreterProtocol

    public init(demoInterpreter: DemoInterpreterProtocol) {
        self.demoInterpreter = demoInterpreter
    }
    
    public func executeCall(restRequest: RestRequest) throws -> Any? {
        
        var stringToParse = ""
        
        //HAY QUE AÑADIR LOS JSON AL TARGET CORRESPONDIENTE (PARA TESTEAR, PONER EL TARGET SanLibraryV3Tests Y AÑADIR A COPY BUNDLE RESOURCES)
        if let filepath = Bundle.main.path(forResource: restRequest.serviceName, ofType: "json") {
            do {
                stringToParse = try String(contentsOfFile: filepath)
            } catch {
                return nil
            }
        } else {
            return nil
        }

        //PARA BUSCAR EL JSON CORRESPONDIENTE AL DNI
        let json = JSON(parseJSON: stringToParse)
        
        guard let filtered = getAnswers(document: json) else {
            return nil
        }
        
        let answerNumber = demoInterpreter.getAnswerNumber(serviceName: restRequest.serviceName)
        
        if filtered.value.count > answerNumber, let dictionary = filtered.value.dictionary, let outputJSON = dictionary["\(answerNumber)"] {
            if let httpCode = outputJSON["httpCode"].int, outputJSON["response"].exists() {
                return RestJSONResponse(httpCode: httpCode, message: outputJSON["response"].description)
            } else {
                return outputJSON.description
            }
        }
        return nil
    }

    // By Default, we try to use specific user answer. In case it does not exist, we fall back the default demo user answer
    public func getAnswers(document: JSON) -> (key: String, value: JSON)? {
        if let demoUserId = demoInterpreter.getDemoUser(), let filtered = document.dictionaryValue.filter({$0.key.lowercased() == demoUserId.lowercased()}).first {
            return filtered
        } else {
            return document.dictionaryValue.filter({$0.key.lowercased() == demoInterpreter.getDefaultDemoUser().lowercased()}).first
        }
    }
    
    public var logTag: String {
        return String(describing: type(of: self))
    }
}
