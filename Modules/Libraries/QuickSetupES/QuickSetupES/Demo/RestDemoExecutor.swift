//
//  RestDemoExecutor.swift
//  SanLibraryV3Tests
//
//  Created by Carlos Pérez Pérez on 2/4/18.
//  Copyright © 2018 com.ciber. All rights reserved.
//

import SANLibraryV3
import SwiftyJSON

class RestDemoExecutor: RestServiceExecutor {
    
    let demoInterpreter: DemoInterpreter

    init(demoInterpreter: DemoInterpreter) {
        self.demoInterpreter = demoInterpreter
    }
    
    func executeCall(restRequest: RestRequest) throws -> Any? {
        var stringToParse = ""
        
        if let filepath = Bundle(for: RestDemoExecutor.self).path(forResource: restRequest.serviceName, ofType: "json") {
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
        
        guard filtered.value.count > answerNumber, let dictionary = filtered.value.dictionary, let outputJSON = dictionary["\(answerNumber)"] else {
            return nil
        }
        guard let httpCode = outputJSON["httpCode"].int, outputJSON["response"].exists() else {
            return outputJSON.description
        }
        switch httpCode {
        case 401:
            throw BSANUnauthorizedException("No autorizado", responseValue: outputJSON["response"].description)
        default:
            return RestJSONResponse(httpCode: httpCode, message: outputJSON["response"].description)
        }
    }

    // By Default, we try to use specific user answer. In case it does not exist, we fall back the default demo user answer
    func getAnswers(document: JSON) -> (key: String, value: JSON)? {
        if let demoUserId = demoInterpreter.getDemoUser(), let filtered = document.dictionaryValue.filter({$0.key.lowercased() == demoUserId.lowercased()}).first {
            return filtered
        } else {
            return document.dictionaryValue.filter({$0.key.lowercased() == demoInterpreter.getDefaultDemoUser().lowercased()}).first
        }
    }
    
    var logTag: String {
        return String(describing: type(of: self))
    }
}
