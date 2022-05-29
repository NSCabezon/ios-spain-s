import Foundation
import OpenCombine
import CoreFoundationLib

public struct MockHomeTipsRepository: HomeTipsRepository {
    public var tipsCount: Int = 0
    
    public init(_ tipsCount: Int) {
        self.tipsCount = tipsCount
    }
    
    public init() {}
    
    public func getHomeTipsCount() -> AnyPublisher<Int, Never> {
        return Just(tipsCount).eraseToAnyPublisher()
    }
}
