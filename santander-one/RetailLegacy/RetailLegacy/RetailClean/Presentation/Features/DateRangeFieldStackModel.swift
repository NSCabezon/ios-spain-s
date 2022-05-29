import Foundation

class DateRangeFieldStackModel: StackItem<DateRangeFieldStackView> {

    private var isVisible: Bool
    private let leftTitle: LocalizedStylableText
    private let rightTitle: LocalizedStylableText
    private let initialDateFrom: Date?
    private let initialDateTo: Date?
    private let minimumDateRange: Date?
    private let maximumDateRange: Date?
    private var changeVisibility: ((Bool) -> Void)?
    private let dependencies: PresentationComponent

    private lazy var dateFrom: DateFieldStackModel = {
        let dateField = DateFieldStackModel(inputIdentifier: DateIdentifier.fromDate, placeholder: .empty, date: initialDateFrom, textFieldStyle: TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left), privateComponent: dependencies, insets: Insets(left: 0, right: 0, top: 0, bottom: 0))
        dateField.delegate = self
        return dateField
    }()
    private lazy var dateTo: DateFieldStackModel = {
        let dateField = DateFieldStackModel(inputIdentifier: DateIdentifier.toDate, placeholder: .empty, date: initialDateTo, textFieldStyle: TextFieldStylist(textColor: .sanGreyDark, font: .latoRegular(size: 16.0), textAlignment: .left), privateComponent: dependencies, insets: Insets(left: 0, right: 0, top: 0, bottom: 0))
        dateField.delegate = self
        return dateField
    }()
    var onSelection: ((Date?, Date?) -> Void)?
    
    init(leftTitle: LocalizedStylableText, rightTitle: LocalizedStylableText, isVisible: Bool = true, initialDateFrom: Date? = nil, initialDateTo: Date? = nil, minimumDateRange: Date?, maximumDateRange: Date?, privateComponent: PresentationComponent, insets: Insets = Insets(left: 10, right: 10, top: 15, bottom: 4)) {
        self.leftTitle = leftTitle
        self.rightTitle = rightTitle
        self.dependencies = privateComponent
        self.isVisible = isVisible
        self.initialDateFrom = initialDateFrom
        self.initialDateTo = initialDateTo
        self.minimumDateRange = minimumDateRange
        self.maximumDateRange = maximumDateRange
        super.init(insets: insets)
    }
    
    func setVisibility(_ isVisible: Bool) {
        self.isVisible = isVisible
        changeVisibility?(isVisible)
    }
        
    override func bind(view: DateRangeFieldStackView) {
        dateFrom.bind(view: view.dateFromView)
        dateTo.bind(view: view.dateToView)
        view.setLeftTitle(leftTitle)
        view.setRightTitle(rightTitle)
        changeVisibility = view.setVisibility
        view.setVisibility(isVisible)
        dateTo.lowerLimitDate = initialDateFrom ?? minimumDateRange
        dateFrom.lowerLimitDate = minimumDateRange
        dateTo.upperLimitDate = maximumDateRange
        dateFrom.upperLimitDate = initialDateTo ?? maximumDateRange
    }
}

extension DateRangeFieldStackModel: DateFieldStackModelDelegate {
    
    struct DateIdentifier {
        static let fromDate = "fromDate"
        static let toDate = "toDate"
    }
    
    func dateChanged(inputIdentifier: String, date: Date?) {
        if inputIdentifier == DateIdentifier.fromDate {
            dateTo.lowerLimitDate = date
        } else {
            dateFrom.upperLimitDate = date
        }
        onSelection?(dateFrom.date, dateTo.date)
    }
    
}
