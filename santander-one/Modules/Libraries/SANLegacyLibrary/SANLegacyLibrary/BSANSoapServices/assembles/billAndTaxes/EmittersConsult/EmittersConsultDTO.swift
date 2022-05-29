import Foundation

public struct EmittersConsultDTO: Codable  {
    public let emitterList: [EmitterDTO]
    public let pagination: PaginationDTO?
    
    public init(emitterList: [EmitterDTO], pagination: PaginationDTO?) {
        self.emitterList = emitterList
        self.pagination = pagination
    }
}

public struct EmitterDTO: Codable {
    public let name: String
    public let code: String
    
    public init(name: String, code: String) {
        self.name = name
        self.code = code
    }
}

public struct EmittersPaginationAdapter {
    let pagination: PaginationDTO?
    
    public init(pagination: PaginationDTO?) {
        self.pagination = pagination
    }
    
    public func getRepositionXML() -> String {
        guard let repositionXML = pagination?.repositionXML else {
            return emptyPagination
        }
        guard !repositionXML.isEmpty else {
            return emptyPagination
        }
        return repositionXML.lowercased().trim().replace(">n<", ">R<")
    }
    
    var emptyPagination: String {
        return """
            <paginacion>
            <indicadorPaginacion>L</indicadorPaginacion>
            <reposAdesc/>
            <reposAqcemis/>
            </paginacion>
            """
    }
}

