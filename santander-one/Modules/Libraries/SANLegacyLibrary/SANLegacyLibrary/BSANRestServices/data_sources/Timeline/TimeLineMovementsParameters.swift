public enum TimeLineDirection: String, Codable {
    case backward
    case forward
    case unknown
    
    init(from string: String) {
        switch string {
        case "forward": self = .forward
        case "backward": self = .backward
        default: self = .unknown
        }
    }
    
    var value: String {
        switch self {
        case .backward:
            return "backward"
        case .forward:
            return "forward"
        case .unknown:
            return ""
        }
    }
}

public struct TimeLineMovementsParameters: Codable {
    /// date of start the search
   public var date: String
    /// used for pagination, it would be the id of the first movement of the page
   public var offset: String
    /// results per page, default 15
   public var limit: Int? = 15
    /// search direction taking date as reference, forward means date to future, bakward means past
   public var direction: TimeLineDirection
 
    public init(date: Date, offset: String = "", limit: Int?, direction: TimeLineDirection) {
        let serviceFormatDate = DateFormats.toString(date: date, output: .YYYYMMDD)
        self.date = serviceFormatDate
        self.offset = offset
        self.limit = limit
        self.direction = direction
    }
}
