public enum LoadBackgroundImageRepositoryError: Error {
    case notImplemented
    case malformed
    case fileNotFound
    case unkonwn
}

public protocol LoadBackgroundImageRepositoryProtocol {
    func load(_ name: String) throws -> [Data]
    func setBaseUrl(_ url: String)
}

public class FtpBackgroundImageRepository {
    private var baseUrl: String?
    private let basePath: String = "apps/SAN/img/background"
    
    public init() {}
}

// MARK: - LoadBackgroundImageRepositoryProtocol

extension FtpBackgroundImageRepository: LoadBackgroundImageRepositoryProtocol {
    public func setBaseUrl(_ url: String) {
        self.baseUrl = url
    }
    
    public func load(_ name: String) throws -> [Data] {
        guard let source = self.baseUrl, var baseUrl: URL = URL(string: source) else {
            throw LoadBackgroundImageRepositoryError.malformed
        }
        baseUrl.appendPathComponent(self.basePath)
        baseUrl.appendPathComponent(name)
        var images: [Data] = []
        for index in 1...10 {
            let url: URL = baseUrl.appendingPathComponent("\(index).jpg")
            do {
                let data: Data = try Data(contentsOf: url)
                images.append(data)
            } catch {
                throw LoadBackgroundImageRepositoryError.fileNotFound
            }
        }
        return images
    }
}
