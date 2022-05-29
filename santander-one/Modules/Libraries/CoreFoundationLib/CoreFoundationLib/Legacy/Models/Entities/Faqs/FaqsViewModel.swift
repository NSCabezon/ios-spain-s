import CoreDomain

public class FaqsViewModel {
    private let faqRepresentable: FaqRepresentable
    public let screenName: String?
    
    public init(_ faqRepresentable: FaqRepresentable, _ screenName: String? = nil) {
        self.faqRepresentable = faqRepresentable
        self.screenName = screenName
    }
    
    public var identifier: Int? {
        return faqRepresentable.identifier
    }
    
    public var keywords: [String]? {
        return faqRepresentable.keywords
    }
    
    public var question: String {
        return faqRepresentable.question
    }
    
    public var answer: String {
        return faqRepresentable.answer
    }
}
