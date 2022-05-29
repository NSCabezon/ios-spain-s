import Foundation

open class StringErrorOutput {

    private let errorDesc: String?

    public init(_ errorDesc: String?) {
        self.errorDesc = errorDesc
    }

    public func getErrorDesc() -> String? {
        return errorDesc
    }
}
