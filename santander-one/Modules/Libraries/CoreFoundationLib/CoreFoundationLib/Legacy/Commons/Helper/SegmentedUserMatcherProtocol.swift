
public protocol SegmentedUserMatcherProtocol {
    func retrieveUserSegment(bdpType: String?, comCode: String?) -> CommercialSegmentsDTO?
    func retrieveDefaultSegment(segmentedUser: [SegmentedUserTypeDTO]?) -> CommercialSegmentsDTO?
}
