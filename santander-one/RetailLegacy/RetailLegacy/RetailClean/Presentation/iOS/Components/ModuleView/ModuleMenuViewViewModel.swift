import Foundation

protocol ModuleMenuSingleOptionProtocol {
    var title: LocalizedStylableText { get }
    var imageKey: String { get }
    var coachmarkId: CoachmarkIdentifier? { get }
}

protocol ModuleMenuMainOptionProtocol: ModuleMenuSingleOptionProtocol {
    var rows: [LocalizedStylableText] { get }
}

protocol ModuleMenuExecutableOptionType {
    var execute: () -> Void { get }
}

struct ModuleSimpleMenuOption: ModuleMenuSimpleOptionType {
    let title: LocalizedStylableText
    let imageKey: String
    let coachmarkId: CoachmarkIdentifier?
    let execute: () -> Void
    
    init(title: LocalizedStylableText, imageKey: String, coachmarkId: CoachmarkIdentifier? = nil, execute: @escaping () -> Void) {
        self.title = title
        self.imageKey = imageKey
        self.coachmarkId = coachmarkId
        self.execute = execute
    }
}

struct ModuleMenuMainOption: ModuleMenuMainOptionType {
    let title: LocalizedStylableText
    let imageKey: String
    let coachmarkId: CoachmarkIdentifier?
    var rows: [LocalizedStylableText]
    let execute: () -> Void
    
    init(title: LocalizedStylableText, imageKey: String, coachmarkId: CoachmarkIdentifier? = nil, rows: [LocalizedStylableText], execute: @escaping () -> Void) {
        self.title = title
        self.imageKey = imageKey
        self.coachmarkId = coachmarkId
        self.rows = rows
        self.execute = execute
    }
}

typealias ModuleMenuSimpleOptionType = ModuleMenuSingleOptionProtocol & ModuleMenuExecutableOptionType
typealias ModuleMenuMainOptionType = ModuleMenuMainOptionProtocol & ModuleMenuExecutableOptionType

class ModuleMenuViewViewModel: HeaderViewModel<ModuleMenuView> {
    
    var simpleOptions = [ModuleMenuSimpleOptionType]() {
        didSet {
            setViewSimpleOptionsClosure?(simpleOptions)
        }
    }
    var mainOption: ModuleMenuMainOption?
    private var setViewSimpleOptionsClosure: (([ModuleMenuSimpleOptionType]?) -> Void)?
    override func configureView(_ view: ModuleMenuView) {
        view.setSimpleOptions(simpleOptions)
        view.setMainOption(mainOption)
        setViewSimpleOptionsClosure = view.setSimpleOptions
    }
    
}
