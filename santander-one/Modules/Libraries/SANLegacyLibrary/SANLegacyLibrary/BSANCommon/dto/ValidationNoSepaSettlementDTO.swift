//

import CoreDomain

public struct ValidationNoSepaSettlementDTO: Codable {
    
    public let impConcepLiqComp: AmountDTO?
    public let impConcepLiqBenefAct: AmountDTO?
    
    public init(impConcepLiqComp: AmountDTO?, impConcepLiqBenefAct: AmountDTO?) {
        self.impConcepLiqComp =  impConcepLiqComp
        self.impConcepLiqBenefAct =  impConcepLiqBenefAct
    }
}

extension ValidationNoSepaSettlementDTO: ValidationNoSepaSettlementRepresentable {
    public var impConcepLiqCompRepresentable: AmountRepresentable? {
        return impConcepLiqComp
    }

    public var impConcepLiqBenefActRepresentable: AmountRepresentable? {
        return impConcepLiqBenefAct
    }
}
