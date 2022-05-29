public struct OrderListDTO: Codable {
    public var orders: [OrderDTO]?
    public var pagination: PaginationDTO?

    public init () {}

    public init (orders: [OrderDTO]?, pagination: PaginationDTO?) {
        self.orders = orders
        self.pagination = pagination
    }
}
