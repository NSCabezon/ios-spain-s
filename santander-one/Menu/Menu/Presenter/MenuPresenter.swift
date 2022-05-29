import CoreFoundationLib

protocol MenuPresenterProtocol {
    var view: MenuViewProtocol? { get set }
    func viewDidLoad()
}

final class MenuPresenter {
    
    weak var view: MenuViewProtocol?
    private let dependenciesResolver: DependenciesResolver
    
    init(dependenciesResolver: DependenciesResolver) {
        self.dependenciesResolver = dependenciesResolver
    }
}

extension MenuPresenter: MenuPresenterProtocol {
    
    func viewDidLoad() {}
}

extension MenuPresenter: TrackerScreenProtocol {
    var screenId: String? {
        return "Menu"
    }
    
    var emmaScreenToken: String? {
        return nil
    }
}

extension MenuPresenter: ScreenTrackable {
    var trackerManager: TrackerManager {
        return dependenciesResolver.resolve(for: TrackerManager.self)
    }
}
