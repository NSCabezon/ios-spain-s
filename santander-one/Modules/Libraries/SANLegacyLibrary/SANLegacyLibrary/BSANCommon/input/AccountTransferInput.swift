public struct AccountTransferInput {
    public var amountDTO: AmountDTO
    public var concept: String
    
    public init(amountDTO: AmountDTO, concept: String){
        self.amountDTO = amountDTO
        self.concept = concept
    }
    
    public mutating func setAmountDTO(amountDTO: AmountDTO) -> AccountTransferInput {
        self.amountDTO = amountDTO;
        return self;
    }
    
    public mutating func setConcept(concept: String) -> AccountTransferInput {
        self.concept = concept;
        return self;
    }
}
