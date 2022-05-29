public class ReposDatosPension: ReposControl {
    public var estatusPlanAport: String = ""
    public var fecAltaPlanaport: String = ""
    public var tipoPlanAport: String = ""
    public var timeStampAltaTabla: String = ""

    override public func getPaginacion() -> PaginationDTO {
        var pagination = PaginationDTO()
        pagination.endList = finLista
        pagination.repositionXML = "<repos>"
                + "         <estatusPlanAport>\(estatusPlanAport)</estatusPlanAport>"
                + "         <fecAltaPlanaport>\(fecAltaPlanaport)</fecAltaPlanaport>"
                + "         <tipoPlanAport>\(tipoPlanAport)</tipoPlanAport>"
                + "         <timeStampAltaTabla>\(timeStampAltaTabla)</timeStampAltaTabla>"
                + "         </repos>"
        return pagination
    }

    override public init() {
        super.init()
    }

    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
