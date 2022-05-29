import Foundation

public protocol CommercialSegmentRepresentable {
    var contactRepresentable: ContactSegmentRepresentable? { get }
    var commercialSegmentType: String? { get }
    var topBarBackgroundSegment: String? { get }
    var semanticSegmentType: SemanticSegmentType { get }
    var isSelect: Bool { get }
    var isUniversity: Bool { get }
}

public enum SemanticSegmentType {
    case spb, select, universitarios, retail
}
