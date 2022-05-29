
public struct DigitalProfilePage: PageWithActionTrackable {
    public typealias ActionType = Action
    public let page =  "/digital_profile"
    
    public enum Action: String {
        case swipe
        case tooltip
        case acceder
    }
    public init() {}
}
