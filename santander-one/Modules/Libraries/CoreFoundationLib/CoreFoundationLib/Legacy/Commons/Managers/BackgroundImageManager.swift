
public protocol BackgroundImageManagerProtocol {}

public class BackgroundImageManager {
    public init() {}
    
    public func setup(_ resolver: DependenciesInjector) {
        resolver.register(for: BackgroundImageRepositoryProtocol.self) { resolver in
            let loadImageRepositoryProtocol: LoadBackgroundImageRepositoryProtocol = resolver.resolve()
            let manageImageRepositoryProtocol: ManageBackgroundImageRepositoryProtocol = resolver.resolve()
            return BackgroundImageRepository(loadImageRepository: loadImageRepositoryProtocol, manageImageRepositoryProtocol: manageImageRepositoryProtocol)
        }
        resolver.register(for: DocumentsBackgroundImageRepositoryProtocol.self) { _ in
            return DocumentsBackgroundImageRepository()
        }
        resolver.register(for: ManageBackgroundImageRepositoryProtocol.self) { resolver in
            return resolver.resolve(for: DocumentsBackgroundImageRepositoryProtocol.self)
        }
        resolver.register(for: GetBackgroundImageRepositoryProtocol.self) { resolver in
            return resolver.resolve(for: DocumentsBackgroundImageRepositoryProtocol.self)
        }
        resolver.register(for: DeleteBackgroundImageRepositoryProtocol.self) { resolver in
            return resolver.resolve(for: DocumentsBackgroundImageRepositoryProtocol.self)
        }
        resolver.register(for: LoadBackgroundImageRepositoryProtocol.self) { _ in
            return FtpBackgroundImageRepository()
        }
    }
}

// MARK: - BackgroundImageManagerProtocol

extension BackgroundImageManager: BackgroundImageManagerProtocol {}
