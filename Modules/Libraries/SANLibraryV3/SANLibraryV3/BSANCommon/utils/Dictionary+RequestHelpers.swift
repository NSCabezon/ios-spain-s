//

import Foundation
public extension Dictionary where Key: Hashable, Value: Any {
    func asQueryString() -> String {
        var output = ""
        guard !self.isEmpty else {
            return output
        }
        for (key, value) in self {
            output += "\(key)=\(value)&"
        }
        let ind = String.Index(utf16Offset: output.count-1, in: output)
        output.remove(at: ind)
        return output
    }
}
