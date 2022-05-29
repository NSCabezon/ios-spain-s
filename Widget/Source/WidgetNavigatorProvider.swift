import Foundation

enum WidgetNavigatorProvider {
    static var todayWidgetNavigator: TodayWidgetNavigatorProtocol {
        return TodayWidgetNavigator()
    }
}
