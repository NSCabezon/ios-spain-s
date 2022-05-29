import Fuzi

class MobileOperatorListDTOParser: DTOParser {
    public static func parse(_ node: XMLElement) -> MobileOperatorListDTO {
        var mobileOperatorListDTO = MobileOperatorListDTO()
        var list = [MobileOperatorDTO]()
        
        for operadora in node.children {
            list.append(MobileOperatorDTOParser.parse(operadora))
        }
        
        mobileOperatorListDTO.mobileOperatorList = list
        
        return mobileOperatorListDTO
    }
}
