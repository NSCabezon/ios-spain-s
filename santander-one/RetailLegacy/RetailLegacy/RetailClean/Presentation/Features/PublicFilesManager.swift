import Foundation
import CoreFoundationLib

class PublicFilesManager: PublicFilesManagerProtocol {
    
    // MARK: - Private attributes
    
    private let useCaseProvider: UseCaseProvider
    private let useCaseHandler: UseCaseHandler
    private let secondayUseCaseHandler: SecondaryUseCaseHandler
    private var arePublicFilesDownloaded: Bool = false
    private var isDownloadingPublicFiles: ThreadSafeProperty<Bool> = ThreadSafeProperty(false)
    private var reloadStrategy: PublicFilesStrategy?
    private var initialLoadStrategy: PublicFilesStrategy?
    
    init(useCaseProvider: UseCaseProvider, useCaseHandler: UseCaseHandler, secondayUseCaseHandler: SecondaryUseCaseHandler) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
        self.secondayUseCaseHandler = secondayUseCaseHandler
    }
    
    typealias ActionBlock = () -> Void
    
    // MARK: - Private attributes
    
    private var subscriptors: ThreadSafeProperty<[String: ActionBlock]> = ThreadSafeProperty([:])
    
    // MARK: - Public methods
    
    /// Method to load all public files
    /// - Parameters:
    ///   - strategy: The strategy to use, see `PublicFilesStrategyType`
    ///   - timeout: The timeout to cancel the operation. Set `0` to no timeout
    func loadPublicFiles(withStrategy strategy: PublicFilesStrategyType, timeout: TimeInterval) {
        guard !isDownloadingPublicFiles.value else { return }
        isDownloadingPublicFiles.value = true
        arePublicFilesDownloaded = false
        createStrategy(for: strategy).loadPublicFiles(timeout: timeout)
    }
    
    /// Method to cancel public files
    /// - Parameter strategy: The strategy to use, see `PublicFilesStrategyType`
    func cancelPublicFilesLoad(withStrategy strategy: PublicFilesStrategyType) {
        guard !arePublicFilesDownloaded else { return }
        getStrategy(for: strategy)?.cancel()
        isDownloadingPublicFiles.value = false
    }
    
    /// Method to remove subscriptor
    /// - Parameter type: The subscriptor to be removed.
    func remove<T>(subscriptor type: T.Type) {
        subscriptors.value.removeValue(forKey: String(describing: type))
    }
    
    /// Method to load all public files
    /// - Parameters:
    ///   - type: The subscriptor to be notified when public files did download
    ///   - strategy:The strategy to use, see `PublicFilesStrategyType`
    ///   - timeout: The timeout to cancel the operation. Set `0` to no timeout
    ///   - subscriptorActionBlock: The block to notify when public files did download
    func loadPublicFiles<T>(addingSubscriptor type: T.Type, withStrategy strategy: PublicFilesStrategyType, timeout: TimeInterval, subscriptorActionBlock: @escaping ActionBlock) {
        guard !isDownloadingPublicFiles.value else { return }
        isDownloadingPublicFiles.value = true
        arePublicFilesDownloaded = false
        add(subscriptor: type, subscriptorActionBlock: subscriptorActionBlock)
        createStrategy(for: strategy).loadPublicFiles(timeout: timeout)
    }
    
    /// Method to add a subscriptor
    /// - Parameters:
    ///   - type: The subscriptor to be notified when public files did download
    ///   - subscriptorActionBlock: The block to notify when public files did download
    func add<T>(subscriptor type: T.Type, subscriptorActionBlock: @escaping ActionBlock) {
        if arePublicFilesDownloaded {
            subscriptorActionBlock()
        }
        subscriptors.value[String(describing: type)] = subscriptorActionBlock
    }
}

private extension PublicFilesManager {
    func createStrategy(for type: PublicFilesStrategyType) -> PublicFilesStrategy {
        let strategy: PublicFilesStrategy
        switch type {
        case .initialLoad:
            strategy = PublicFilesStrategy(
                useCaseProvider: useCaseProvider,
                useCaseHandler: useCaseHandler,
                delegate: self
            )
            self.initialLoadStrategy = strategy
        case .reload:
            strategy = PublicFilesStrategy(
                useCaseProvider: useCaseProvider,
                useCaseHandler: secondayUseCaseHandler,
                delegate: self
            )
            self.reloadStrategy = strategy
        }
        return strategy
    }
    
    func getStrategy(for type: PublicFilesStrategyType) -> PublicFilesStrategy? {
        switch type {
        case .initialLoad:
            return initialLoadStrategy
        case .reload:
            return reloadStrategy
        }
    }
}

extension PublicFilesManager: PublicFilesStrategyDelegate {
    
    func publicFilesDidFinishLoading() {
        arePublicFilesDownloaded = true
        isDownloadingPublicFiles.value = false
        subscriptors.value.forEach { $0.value() }
    }
}
