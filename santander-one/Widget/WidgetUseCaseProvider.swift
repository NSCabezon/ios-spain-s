import CoreFoundationLib
import RetailLegacy

public class WidgetUseCaseProvider {
    func getLanguagesSelectionUseCase() -> UseCase<Void, WidgetLanguageUseCaseOkOutput, StringErrorOutput> {
        return WidgetDependencies.languageUseCas
    }
    
    func getMetricsTrackUseCase(input: MetricsTrackUseCaseInput) -> UseCase<MetricsTrackUseCaseInput, Void, StringErrorOutput> {
        return WidgetDependencies.metricsTrackUseCase(input: input)
    }
    
    func getEmmaTrackUseCase(input: EmmaTrackUseCaseInput) -> UseCase<EmmaTrackUseCaseInput, Void, StringErrorOutput> {
        return EmmaTrackUseCase().setRequestValues(requestValues: input)
    }
}
