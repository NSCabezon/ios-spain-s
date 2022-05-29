struct CopyType: Hashable {
    let tag: Int
    let info: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(tag)
    }
    
    static func == (lhs: CopyType, rhs: CopyType) -> Bool {
        return lhs.tag == rhs.tag
    }
}
