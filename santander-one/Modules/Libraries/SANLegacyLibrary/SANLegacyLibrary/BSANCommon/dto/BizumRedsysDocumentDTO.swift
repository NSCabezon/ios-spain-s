//
//  BizumRedsysDocumentDTO.swift
//  SANLegacyLibrary
//
//  Created by José Carlos Estela Anguita on 18/3/21.
//

import Foundation

public struct BizumRedsysDocumentDTO: Codable {
    
    public struct Document: Codable {
        public let type: String
        public let code: String
        
        enum CodingKeys: String, CodingKey {
            case type = "tipodocumpersonacorp", code = "codigodocumpersonacorp"
        }
    }
    
    public let document: Document
    
    enum CodingKeys: String, CodingKey {
        case document = "documento"
    }
    
    public init(type: String, code: String) {
        self.document = Document(type: type, code: code)
    }
}
