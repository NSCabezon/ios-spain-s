public struct SubContractDTO: Codable {
    public var contract: ContractDTO?
    public var subcontractString: String?
    
    public init() {}
    
    public var description: String {
        var text = "";
        if let contract = contract {
            text += "contract= \(contract), ";
        }
        if let subcontractString = subcontractString {
            text += "subcontract" + subcontractString + ", ";
        }
        return "".elementsEqual(text) ? "nil!" : text.substring(0, text.count - 2) ?? "nil!";
        
    }
}
