//
//  BizumDocumentEntity.swift
//  Bizum
//
//  Created by José Carlos Estela Anguita on 18/3/21.
//

import SANLegacyLibrary

public struct BizumDocumentEntity {
    public let type: String
    public let code: String
    
    public var dto: BizumRedsysDocumentDTO {
        return BizumRedsysDocumentDTO(type: self.type, code: self.code)
    }
    
    public init(personBasicData: PersonBasicDataDTO) {
        self.type = personBasicData.documentType?.rawValue ?? ""
        self.code = personBasicData.documentNumber ?? ""
    }
    
    public init(redsysDocument: BizumRedsysDocumentDTO) {
        self.type = redsysDocument.document.type.trim()
        self.code = redsysDocument.document.code
    }
}
