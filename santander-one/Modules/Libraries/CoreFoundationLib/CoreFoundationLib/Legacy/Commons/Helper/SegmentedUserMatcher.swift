
public class SegmentedUserMatcher: SegmentedUserMatcherProtocol {
    
    private let isPB: Bool
    private let repository: SegmentedUserRepository?
    
    private let bdpTypeDefault = "Default"
    private let comCodeDefault = "Default"
    
    public init(isPB: Bool, repository: SegmentedUserRepository? = nil) {
        self.isPB = isPB
        self.repository = repository
    }
    
    public func retrieveUserSegment(bdpType: String?, comCode: String?) -> CommercialSegmentsDTO? {

        let segmentedUserArray = isPB ? repository?.getSegmentedUserSpb() : repository?.getSegmentedUserGeneric()
        guard let segmentedUser = segmentedUserArray else { return nil }
        
        var segmentedUserTypes = segmentedUser.filter { $0.bdpType == bdpType }
        if segmentedUserTypes.isEmpty {
            segmentedUserTypes = segmentedUser.filter { $0.bdpType == bdpTypeDefault }
        }
        // Not even "Default" bdpType inside json file. No data. At least "Default" in bdpType json is mandatory
        guard let segmentedUserType = segmentedUserTypes.first else {
            return nil
        }
        
        var commercialSegments = segmentedUserType.commercialSegments.filter { $0.commercialType == comCode }
        if commercialSegments.isEmpty {
            commercialSegments = segmentedUserType.commercialSegments.filter { $0.commercialType == comCodeDefault }
        }
        // Not even "Default" comCode. Then return bdpType: "Default" comCode: "Default"
        guard let commercialSegment = commercialSegments.first else {
            return retrieveDefaultSegment(segmentedUser: segmentedUser)
        }
        
        return commercialSegment
    }
    
    public func retrieveDefaultSegment(segmentedUser: [SegmentedUserTypeDTO]?) -> CommercialSegmentsDTO? {
        guard let segmentedUser = segmentedUser else { return nil }
        let segmentedUserTypes = segmentedUser.filter { $0.bdpType == bdpTypeDefault }
        guard let defaultSegmentedUserType = segmentedUserTypes.first else { return nil }
        return defaultSegmentedUserType.commercialSegments.filter { $0.commercialType == comCodeDefault }.first
    }
}
