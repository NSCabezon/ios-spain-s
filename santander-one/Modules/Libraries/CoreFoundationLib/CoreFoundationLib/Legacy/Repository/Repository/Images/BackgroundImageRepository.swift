public protocol BackgroundImageRepositoryProtocol {
    func loadWithName(_ name: String, baseUrl: String, oldName: String?) -> Bool
}

public class BackgroundImageRepository {
    private let loadImageRepository: LoadBackgroundImageRepositoryProtocol
    private let manageImageRepositoryProtocol: ManageBackgroundImageRepositoryProtocol
    
    public init(loadImageRepository: LoadBackgroundImageRepositoryProtocol, manageImageRepositoryProtocol: ManageBackgroundImageRepositoryProtocol) {
        self.loadImageRepository = loadImageRepository
        self.manageImageRepositoryProtocol = manageImageRepositoryProtocol
    }
}

// MARK: - Private Methods

private extension BackgroundImageRepository {
    func getImagesWithName(_ name: String, baseUrl: String) -> [Data]? {
        self.loadImageRepository.setBaseUrl(baseUrl)
        do {
            return try self.loadImageRepository.load(name)
        } catch {
            return nil
        }
    }
}

// MARK: - BackgroundImageRepositoryProtocol

extension BackgroundImageRepository: BackgroundImageRepositoryProtocol {
    public func loadWithName(_ name: String, baseUrl: String, oldName: String?) -> Bool {
        guard let images = getImagesWithName(name, baseUrl: baseUrl) else {
            return false
        }
        self.manageImageRepositoryProtocol.delete(name)
        do {
            try self.manageImageRepositoryProtocol.save(name, images: images)
        } catch {
            self.manageImageRepositoryProtocol.delete(name)
            return false
        }
        if let deleteName = oldName {
            self.manageImageRepositoryProtocol.delete(deleteName)
        }
        return true
    }
}
