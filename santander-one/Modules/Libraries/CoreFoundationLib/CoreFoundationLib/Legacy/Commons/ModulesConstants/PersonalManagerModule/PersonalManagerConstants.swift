
public struct PersonalManagerPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/my_manager"
    public enum Action: String {
        case call = "call_manager"
        case email = "send_emailto_manager"
        case schedule = "request_appointment"
        case chat = "open_chat"
        case rate = "rate_your_manager"
    }
    public init() {}
}

public struct NoPersonalManagerPage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page = "/my_manager_without_service"
    public enum Action: String {
        case register = "join_manager_service"
    }
    public init() {}
}
