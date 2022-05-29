import Fuzi

class ValidationNoSepaSettlementParser: DTOParser {
    
    public static func parse(_ node: XMLElement) -> ValidationNoSepaSettlementDTO {
        return ValidationNoSepaSettlementDTO(
            impConcepLiqComp: node.firstChild(tag: "impConcepLiqComp").map({ AmountDTOParser.parse($0) }),
            impConcepLiqBenefAct: node.firstChild(tag: "impConcepLiqBenefAct").map({ AmountDTOParser.parse($0) })
        )
    }
}
