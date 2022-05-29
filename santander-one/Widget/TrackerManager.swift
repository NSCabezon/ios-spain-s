import CoreFoundationLib
import Foundation
import RetailLegacy

public class TrackerManagerImpl {
    private let usecaseProvider: WidgetUseCaseProvider
    private let usecaseHandler: UseCaseHandler
    
    public init(usecaseProvider: WidgetUseCaseProvider, usecaseHandler: UseCaseHandler) {
        self.usecaseProvider = usecaseProvider
        self.usecaseHandler = usecaseHandler
    }
    
    private func track(type: MetricsTrackType, screenId: String, extraParameters: [String: String]) {
        let input = MetricsTrackUseCaseInput(extraParameters: extraParameters, screenId: screenId, type: type)
        let usecase = usecaseProvider.getMetricsTrackUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: usecaseHandler, queuePriority: Operation.QueuePriority.veryLow)
    }
}

extension TrackerManagerImpl: TrackerManager {
    public func trackScreen(screenId: String, extraParameters: [String: String]) {
        track(type: .screen, screenId: screenId, extraParameters: extraParameters)
    }
    
    public func trackEvent(screenId: String, eventId: String, extraParameters: [String: String]) {
        track(type: .event(eventId: eventId), screenId: screenId, extraParameters: extraParameters)
    }
    
    public func trackEmma(token: String) {
        let input = EmmaTrackUseCaseInput(trackToken: token)
        let usecase = usecaseProvider.getEmmaTrackUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: usecaseHandler, queuePriority: Operation.QueuePriority.veryLow)
    }
}
