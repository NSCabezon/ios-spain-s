public typealias DocumentsBackgroundImageRepositoryProtocol = GetBackgroundImageRepositoryProtocol & ManageBackgroundImageRepositoryProtocol

public protocol GetBackgroundImageRepositoryProtocol {
    func get(_ name: String) -> [Data]
}

public protocol DeleteBackgroundImageRepositoryProtocol {
    func delete(_ name: String)
}

public protocol ManageBackgroundImageRepositoryProtocol: DeleteBackgroundImageRepositoryProtocol {
    func save(_ name: String, images: [Data]) throws
}

public class DocumentsBackgroundImageRepository {
    private let fileManager: FileManager
    
    public init() {
        self.fileManager = FileManager.default
    }
}

// MARK: - ImageRepositoryProtocol

extension DocumentsBackgroundImageRepository: ManageBackgroundImageRepositoryProtocol {
    public func save(_ name: String, images: [Data]) throws {
        var baseUrl: URL = try self.fileManager.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true)
        baseUrl.appendPathComponent(name)
        if !self.fileManager.fileExists(atPath: baseUrl.path) {
            try self.fileManager.createDirectory(at: baseUrl, withIntermediateDirectories: true, attributes: nil)
        }
        for index in 0..<images.count {
            let data: Data = images[index]
            let url = baseUrl.appendingPathComponent("\(index+1).jpg")
            try data.write(to: url)
        }
    }
    
    public func delete(_ name: String) {
        guard var baseUrl: URL = try? self.fileManager.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true) else {
            return
        }
        baseUrl.appendPathComponent(name)
        guard self.fileManager.fileExists(atPath: baseUrl.path) else {
            return
        }
        guard let items: [URL] = try? self.fileManager.contentsOfDirectory(at: baseUrl, includingPropertiesForKeys: nil, options: []) else {
            return
        }
        for item in items {
            try? self.fileManager.removeItem(at: item)
        }
        try? self.fileManager.removeItem(at: baseUrl)
    }
}

extension DocumentsBackgroundImageRepository: GetBackgroundImageRepositoryProtocol {
    public func get(_ name: String) -> [Data] {
        var images: [Data] = []
        guard var baseUrl: URL = try? self.fileManager.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: true) else {
            return images
        }
        baseUrl.appendPathComponent(name)
        guard let items: [URL] = try? self.fileManager.contentsOfDirectory(at: baseUrl, includingPropertiesForKeys: nil, options: []) else {
            return images
        }
        for item in items {
            do {
                let data: Data = try Data(contentsOf: item)
                images.append(data)
            } catch {
                return []
            }
        }
        return images
    }
}
