public enum BackgroundImagesTheme {
    case geographic
    case pets
    case geometric
    case architecture
    case experiences
    case nature
    case sports
    case custom(identifier: Int, name: String, trackName: String)
    
    public var isLocalTheme: Bool {
        switch self {
        case .nature:
            return true
        case .geographic, .pets, .geometric, .architecture, .experiences, .sports, .custom(identifier: _, name: _, trackName: _):
            return false
        }
    }
    
    public var name: String {
        switch self {
        case .nature:
            return "bg_nature"
        case .geographic:
            return "geographical"
        case .pets:
            return "pets"
        case .geometric:
            return "geometry"
        case .architecture:
            return "architecture"
        case .experiences:
            return "experiences"
        case .sports:
            return "sports"
        case .custom(identifier: _, name: let name, trackName: _):
            return name
        }
    }
    
    public var trackName: String {
        switch self {
        case .geographic:
            return "geo"
        case .pets:
            return "mas"
        case .geometric:
            return "for"
        case .architecture:
            return "arq"
        case .experiences:
            return "exp"
        case .nature:
            return "nat"
        case .sports:
            return "dep"
        case .custom(identifier: _, name: _, trackName: let trackName):
            return trackName
        }
    }
    
    public var id: Int {
        switch self {
        case .geographic:
            return 0
        case .pets:
            return 1
        case .geometric:
            return 2
        case .architecture:
            return 3
        case .experiences:
            return 4
        case .nature:
            return 5
        case .sports:
            return 6
        case .custom(identifier: let identifier, name: _, trackName: _):
            return identifier
        }
    }
    
    public init?(id: Int) {
        switch id {
        case 0:
            self = .geographic
        case 1:
            self = .pets
        case 2:
            self = .geometric
        case 3:
            self = .architecture
        case 4:
            self = .experiences
        case 5:
            self = .nature
        case 6:
            self = .sports
        default:
            return nil
        }
    }
    
    public static var defaultTheme: Int {
        return BackgroundImagesTheme.nature.id
    }
}

extension BackgroundImagesTheme: Equatable {
    
}
