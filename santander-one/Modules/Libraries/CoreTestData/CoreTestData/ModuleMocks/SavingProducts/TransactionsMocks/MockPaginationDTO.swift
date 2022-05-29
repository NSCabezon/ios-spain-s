import CoreDomain
import OpenCombine

struct MockPaginationDTO: Codable {
    var next: String?
    var current: String?
    
    enum CodingKeys: String, CodingKey {
        case next = "Next"
        case current = "Self"
    }
    
    init () {}
        
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let dictionary = try container.decode([String: String].self)
        let next = MockPaginationDTO.pageForPaginationFromURL(dictionary[CodingKeys.next.rawValue])
        let current = MockPaginationDTO.pageForPaginationFromURL(dictionary[CodingKeys.current.rawValue])
        self.next = next
        self.current = current
    }
}

extension MockPaginationDTO: SavingPaginationRepresentable {}

private extension MockPaginationDTO {
    static func pageForPaginationFromURL(_ url: String?) -> String? {
        guard let stringUrl = url,
              let urlComponents = URLComponents(string: stringUrl),
              let pageQueryItem = urlComponents.queryItems?.first(where: {$0.name == "page"}) else {
            return nil
        }
        return pageQueryItem.value
    }
}
