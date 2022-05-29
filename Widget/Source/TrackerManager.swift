import CoreFoundationLib
import RetailLegacy

public class TrackerManager {
    private let usecaseHandler: UseCaseHandler
    
    public init(usecaseHandler: UseCaseHandler) {
        self.usecaseHandler = usecaseHandler
    }
    
    public func trackEvent(screenId: String, eventId: String, extraParameters: [String: String]) {
        let input = MetricsTrackUseCaseInput(extraParameters: extraParameters, screenId: screenId, type: .event(eventId: eventId))
        let usecase = WidgetDependencies.metricsTrackUseCase(input: input)
        UseCaseWrapper(with: usecase, useCaseHandler: usecaseHandler, queuePriority: Operation.QueuePriority.veryLow)
    }
}
