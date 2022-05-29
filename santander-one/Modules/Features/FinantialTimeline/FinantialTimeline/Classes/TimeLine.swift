import Foundation

public class TimeLine {
    
    // MARK: - Private
    
    internal static var dependencies = Dependencies()
    
    // MARK: - Public API
    
    /// Method to setup the TimeLine module. It is mandatory to call this method before doing anything.
    /// - Parameter configuration: An entity that conforms the Configuration entity.
    public static func setup(configuration: Configuration) {
        dependencies = Dependencies()
        dependencies.configuration = configuration
    }
    
    /// Method to setup the TimeLine module. It is mandatory to call this method before doing anything.
    /// - Parameter configuration: An entity that conforms the Configuration entity.
    /// - Parameter restClient: An entity that conforms the RestClient protocol. Use this entity to override the way that the module perform the network requests.
    public static func setup(configuration: Configuration, restClient: RestClient) {
        dependencies = Dependencies()
        dependencies.restClient = restClient
        dependencies.configuration = configuration
    }
    
    /// Method to load the TimeLineViewController
    ///
    /// - Returns: The TimeLineViewController
    public static func load() -> UIViewController {
        guard let strategy = dependencies.getStrategy(),
        let timeLineViewController = strategy.createModule(dependencies: dependencies) else { fatalError("The timeline couldn't be loaded") }
        return timeLineViewController
    }
    
    /// Method to load the widget
    ///
    /// - Parameter days: The number of days from today to search for elements.
    /// - Parameter elements: Maximum elements to show
    /// - Returns: The widget view
    public static func loadWidget(days: Int = 7, elements: Int = 3) -> UIView {
        guard let strategy = dependencies.getStrategy(),
            let widgetView = strategy.createWidgetModule(dependencies: dependencies, days: days, elements: elements) else { fatalError("The timeline couldn't be loaded") }
        return widgetView
    }
    
    /// Method to erese any data saved in the component
    public static func resetStorage() {
        let _ = SecureStorageHelper.resetBlackList()
    }
    
    /// Returns the module version number.
    ///
    /// - Returns: A string with the version number
    public static func version() -> String? {
        return Bundle.module?.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

protocol TimeLineStrategy {
    func createModule(dependencies: Dependencies) -> UIViewController?
    func createWidgetModule(dependencies: Dependencies, days: Int, elements: Int) -> UIView?
}

class TimeLineNativeStrategy: TimeLineStrategy {
    func createModule(dependencies: Dependencies) -> UIViewController? {
        dependencies.configurationEngine.load()
        guard let timeLineViewController = TimeLineRouter.createModule(dependencies: dependencies) else { fatalError("The timeline couldn't be loaded") }
        return timeLineViewController
    }
    
    func createWidgetModule(dependencies: Dependencies, days: Int, elements: Int) -> UIView? {
        dependencies.configurationEngine.load()
        let widgetView = TimeLineRouter.createWidgetModule(dependencies: dependencies, days: days, elements: elements)
        return widgetView
    }
}

class TimeLineHybridStrategy: TimeLineStrategy {
    func createModule(dependencies: Dependencies) -> UIViewController? {
        guard let timeLineController = TimeLineRouter.createHybridModule(dependencies: dependencies) else { fatalError("The timeline couldn't be loaded") }
        return timeLineController
    }
    
    func createWidgetModule(dependencies: Dependencies, days: Int, elements: Int) -> UIView? {
        return nil
    }
}
