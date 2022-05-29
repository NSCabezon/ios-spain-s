import Foundation

class ClearableSearchSection: Hashable {
    let criteria: SearchCriteria
    private var sections = [Clearable]()
    
    init(criteria: SearchCriteria, sections: [Clearable]) {
        self.criteria = criteria
        self.sections = sections
    }
    
    func clearAll() {
        sections.forEach { (s) in
            s.clear()
        }
    }
    
    func addClearableSection(_ section: Clearable) {
        sections.append(section)
    }
    
    // MARK: Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(criteria.hashValue)
    }
    
    static func == (lhs: ClearableSearchSection, rhs: ClearableSearchSection) -> Bool {
        return lhs.criteria == rhs.criteria
    }
    
}
