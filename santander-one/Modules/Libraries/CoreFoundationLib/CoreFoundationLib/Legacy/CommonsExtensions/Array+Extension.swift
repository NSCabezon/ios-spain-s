import Foundation

public extension Sequence {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var categories: [U: [Iterator.Element]] = [:]
        for element in self {
            let key = key(element)
            if case nil = categories[key]?.append(element) {
                categories[key] = [element]
            }
        }
        return categories
    }
}

public extension Array {
    /// Returns an array containing this sequence shuffled
    var shuffled: Array {
        var elements = self
        return elements.shuffle()
    }
    
    /// Shuffles this sequence in place
    @discardableResult
    mutating func shuffle() -> Array {
        indices.dropLast().forEach {
            guard case let index = Int(arc4random_uniform(UInt32(count - $0))) + $0, index != $0 else {
                return
            }
            swapAt($0, index)
        }
        return self
    }
    
    var randomItem: Element {
        return self[Int(arc4random_uniform(UInt32(count)))]
    }
    
    func randomItems(maxItems: Int) -> Array {
        return Array(shuffled.prefix(maxItems))
    }
    
    func mapOptionals<U>(_ transform: (Element) -> U?) -> [U]? {
        var result: [U] = []
        
        for elem in self {
            if let mapped = transform(elem) {
                result.append(mapped)
            } else {
                return nil
            }
        }
        
        return result
    }
    
    func mapSkipNils<U>(_ transform: (Element) -> U?) -> [U] {
        var result: [U] = []
        
        for elem in self {
            if let mapped = transform(elem) {
                result.append(mapped)
            }
        }
        
        return result
    }
    
    func element(atIndex index: Int) -> Element? {
        if count > index {
            return self[index]
        }
        return nil
    }
    
    func find(_ includedElement: (Element) -> Bool) -> Int? {
        for (idx, element) in enumerated() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
    
    mutating func removeIfFound(_ includedElement: (Element) -> Bool) {
        if let i = self.find(includedElement) {
            self.remove(at: i)
        }
    }
    
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
    
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    mutating func append(_ newElement: Element, conditionedBy condition: Bool) {
        if condition {
            append(newElement)
        }
    }
    
    mutating func append(_ newElement: Element, conditionedBy condition: @escaping (Element) -> Bool) {
        if condition(newElement) {
            append(newElement)
        }
    }
}
