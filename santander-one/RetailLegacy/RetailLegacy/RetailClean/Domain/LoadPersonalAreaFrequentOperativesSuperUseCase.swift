import Foundation
import CoreFoundationLib
import SANLegacyLibrary

class LoadPersonalAreaFrequentOperativesSuperUseCase {
    
    private let maximumSelectableOptions = 6
    private let useCaseProvider: UseCaseProvider
    private let useCaseHandler: UseCaseHandler
    private var allFrequentOperatives = [FrequentOperative]()
    private lazy var checker: FrequentDirectLinkChecker = {
       return FrequentDirectLinkChecker(useCaseProvider: useCaseProvider, useCaseHandler: useCaseHandler)
    }()
    var onlyActiveOperatives = false
    
    init(useCaseProvider: UseCaseProvider, useCaseHandler: UseCaseHandler) {
        self.useCaseProvider = useCaseProvider
        self.useCaseHandler = useCaseHandler
    }
    
    func execute(onCompletion: @escaping ([FrequentOperative], Int) -> Void) {
        let useCase = useCaseProvider.getPersonalAreaFrequentOperativesUseCase()
        UseCaseWrapper(with: useCase, useCaseHandler: useCaseHandler, errorHandler: nil, includeAllExceptions: true, queuePriority: .normal, onSuccess: { [weak self] (response) in
            self?.verifyAvailable(response.frequentOperatives, completion: onCompletion)
            }, onError: { [weak self] _ in
                self?.allFrequentOperatives = []
        })
    }
    
    private func verifyAvailable(_ favoriteLinks: [FrequentOperative], completion: @escaping ([FrequentOperative], Int) -> Void) {
        allFrequentOperatives =  onlyActiveOperatives ? favoriteLinks.filter({$0.isEnabled == true}) : favoriteLinks
        let dispatchGroup = DispatchGroup()
        let items = allFrequentOperatives.map { $0.directLink }
        for directLink in items {
            dispatchGroup.enter()
            checker.isDirectLinkAvailable(directLink) { [weak self] (isPresent) in
                defer {
                    dispatchGroup.leave()
                }
                guard isPresent == false else { return }
                if let (item, _) = self?.allFrequentOperatives.enumerated().first(where: { $0.element.directLink == directLink }) {
                    self?.allFrequentOperatives.remove(at: item)
                }
            }
        }
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            completion(self?.allFrequentOperatives ?? [], self?.maximumSelectableOptions ?? 0)
        }
    }
    
}
