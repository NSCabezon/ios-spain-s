public struct RMVDetailDTO: Codable {
    public var rmvLineDetailModelList: [RMVLineDetailDTO] = []
    public var stockDesc: String?

    public init() {}
}
