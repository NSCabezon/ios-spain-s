import Foundation

class WidgetPresenterProvider {
    
    static var todayWidgetPresenter: TodayWidgetPresenterProtocol {
        return TodayWidgetPresenter()
    }
    
}
