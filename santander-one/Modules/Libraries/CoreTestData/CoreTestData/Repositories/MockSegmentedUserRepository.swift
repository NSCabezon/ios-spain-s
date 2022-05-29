import CoreFoundationLib
import Foundation
import OpenCombine
import CoreDomain

public struct MockSegmentedUserRepository: SegmentedUserRepository {
    private let mockDataInjector: MockDataInjector
    private var commercialSegment: CommercialSegmentRepresentable? {
        switch segmentedUser {
        case .empty:
            return nil
        case let .fraudNumbers(phones):
            return CommercialSegmentRepresentableMock(phones)
        }
    }
    
    private var segmentedUser: MockSegmentedUser
    
    public init(mockDataInjector: MockDataInjector, _ segmentedUser: MockSegmentedUser = .empty) {
        self.mockDataInjector = mockDataInjector
        self.segmentedUser = segmentedUser
    }
    public func getSegmentedUser() -> SegmentedUserDTO? {
        return self.mockDataInjector.mockDataProvider.segmentedUser.getSegmentedUser
    }
    public func getSegmentedUserSpb() -> [SegmentedUserTypeDTO]? {
        return self.getSegmentedUser()?.spb
    }
    public func getSegmentedUserGeneric() -> [SegmentedUserTypeDTO]? {
        return self.getSegmentedUser()?.generic
    }
    public func getCommercialSegment() -> AnyPublisher<CommercialSegmentRepresentable?, Never> {
        return Just(commercialSegment)
            .eraseToAnyPublisher()
    }
    
    public func remove() { }
    
    public func load(withBaseUrl url: String) { }
    
    public func load(baseUrl: String, publicLanguage: PublicLanguage) { }
}

private struct CommercialSegmentRepresentableMock: CommercialSegmentRepresentable {
    var contactRepresentable: ContactSegmentRepresentable?
    var commercialSegmentType: String?
    var topBarBackgroundSegment: String?
    var semanticSegmentType: SemanticSegmentType = .spb
    var isSelect: Bool = true
    var isUniversity: Bool = true
    
    init(_ fraudNumbers: [String] = []) {
        self.contactRepresentable = ContactSegmentRepresentableMock(fraudNumbers)
    }
}

private struct ContactSegmentRepresentableMock: ContactSegmentRepresentable {
    var superlineaRepresentable: ContactPhoneRepresentable? = nil
    var cardBlockRepresentable: ContactPhoneRepresentable? = nil
    var fraudFeedbackRepresentable: ContactPhoneRepresentable? = nil
    var twitterContactRepresentable: ContactSocialNetworkRepresentable? = nil
    var facebookContactRepresentable: ContactSocialNetworkRepresentable? = nil
    var whatsAppContactRepresentable: ContactSocialNetworkRepresentable? = nil
    var mailContactRepresentable: ContactSocialNetworkRepresentable? = nil
    
    init(_ fraudNumbers: [String]) {
        fraudFeedbackRepresentable = ContactPhoneRepresentableMock(fraudNumbers)
    }
}

private struct ContactPhoneRepresentableMock: ContactPhoneRepresentable {
    var title: String?
    var desc: String?
    var numbers: [String]?
    
    init(_ fraudNumbers: [String]) {
        numbers = fraudNumbers
    }
}

public enum MockSegmentedUser {
    case empty
    case fraudNumbers(phones: [String])
}
