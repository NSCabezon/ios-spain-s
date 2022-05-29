public struct LiteralDTO: Codable {
    public var concept: String?
    public var literal: String?
    
    public init (concept: String, literal: String){
        self.concept = concept
        self.literal = literal
    }
}
