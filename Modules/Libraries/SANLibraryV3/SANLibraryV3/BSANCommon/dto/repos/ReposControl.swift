public class ReposControl: Codable {

    public var finLista: Bool = true
    public var clavePaginacion: String = ""
    public var indRepos: String = ""

    public init() {
    }

    public init(_ finLista: Bool, _ clavePaginacion: String, _ indRepos: String) {
        self.finLista = finLista
        self.clavePaginacion = clavePaginacion
        self.indRepos = indRepos
    }

    public func getPaginacion() -> PaginationDTO {
		var pagination = PaginationDTO()
        pagination.endList = finLista
        pagination.repositionXML = "<repos><clavePaginacion>\(clavePaginacion)</clavePaginacion><indRepos>\(indRepos)</indRepos></repos>"
        return pagination
    }
}
