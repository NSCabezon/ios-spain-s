import Foundation

public protocol CommercialSegmentRepresentable {
    var contactRepresentable: ContactSegmentRepresentable? { get }
    var commercialSegmentType: String? { get }
    var topBarBackgroundSegment: String? { get }
    var semanticSegmentType: SemanticSegmentType { get }
    func isSelect() -> Bool
    func isUniversity() -> Bool
}

public enum SemanticSegmentType {
    case spb, select, universitarios, retail
}
