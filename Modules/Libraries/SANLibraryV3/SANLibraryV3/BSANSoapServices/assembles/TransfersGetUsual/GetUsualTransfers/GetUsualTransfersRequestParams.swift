import Foundation

public struct GetUsualTransfersRequestParams {
    public var token: String
    public var userDataDTO: UserDataDTO
    public var language: String
    public var dialect: String
    public var pagination: PaginationDTO?
}
