import CoreFoundationLib
import OpenCombine
import UI

final class SavingHeaderActionsView: XibView {
    @IBOutlet weak var movementsLabel: UILabel!
    @IBOutlet weak var downloadButton: PressableButton!
    @IBOutlet weak var filterButton: PressableButton!
    @IBOutlet weak var pdfLabel: UILabel!
    @IBOutlet weak var filterLabel: UILabel!
    
    @IBOutlet weak var filtersContainerView: UIView!
    @IBOutlet weak var pdfContainerView: UIView!

    @IBOutlet private weak var pdfStackView: UIStackView!
    @IBOutlet private weak var filterStackView: UIStackView!
    @IBOutlet private weak var separatorView: UIView!
    private let stateSubject = CurrentValueSubject<SavingHeaderAction, Never>(.idle)
    var state: AnyPublisher<SavingHeaderAction, Never>

    override init(frame: CGRect) {
        state = stateSubject.eraseToAnyPublisher()
        super.init(frame: frame)
        setupView()
        setAccessibilityIds()
        setAccessibilityLabels()
    }
    
    required init?(coder: NSCoder) {
        state = stateSubject.eraseToAnyPublisher()
        super.init(coder: coder)
        setupView()
        setAccessibilityIds()
        setAccessibilityLabels()
    }
    
    func togglePdfDownload(toHidden hidden: Bool) {
        pdfContainerView.isHidden = hidden
    }
    
    func toggleFilters(toHidden hidden: Bool) {
        filtersContainerView.isHidden = hidden
    }
}

// MARK: - Private
private extension SavingHeaderActionsView {
    func setupView() {
        self.clipsToBounds = true
        self.movementsLabel.scaledFont = UIFont.santander(family: .text, type: .bold, size: 16)
        self.movementsLabel.text =  localized("productHome_label_moves").uppercased()
        self.downloadButton.setImage(Assets.image(named: "icnDownload"), for: .normal)
        self.pdfLabel.configureText(withKey: "generic_button_downloadPDF")
        self.pdfLabel.textColor = UIColor.darkTorquoise
        self.filterLabel.configureText(withKey: "generic_button_filters")
        self.filterLabel.textColor = UIColor.darkTorquoise
        self.filterButton.setImage(Assets.image(named: "icnFilter"), for: .normal)
        self.separatorView.backgroundColor = .mediumSkyGray
        self.setButtonsGestureEvent()
    }
    
    func setButtonsGestureEvent() {
        let downloandGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnDownloadMovements))
        let filterGesture = UITapGestureRecognizer(target: self, action: #selector(didTapOnFilterMovements))
        self.downloadButton.addGestureRecognizer(downloandGesture)
        self.filterButton.addGestureRecognizer(filterGesture)
    }
    
    func setAccessibilityIds() {
        self.accessibilityIdentifier = "SavingHome_view_moves"
        self.downloadButton.accessibilityIdentifier = "icn_download"
        self.pdfLabel.accessibilityIdentifier = "generic_button_downloadPDF"
        self.filterLabel.accessibilityIdentifier = "generic_button_filters"
        self.filterButton.accessibilityIdentifier = "icn_filter"
        self.movementsLabel.accessibilityIdentifier = "productHome_label_moves"
    }
    
    func setAccessibilityLabels() {
        self.pdfLabel.isAccessibilityElement = false
        self.downloadButton.isAccessibilityElement = false
        self.pdfStackView.isAccessibilityElement = true
        self.pdfStackView.accessibilityTraits = .button
        self.pdfStackView.accessibilityLabel = localized("generic_button_downloadPDF")
        self.filterLabel.isAccessibilityElement = false
        self.filterButton.isAccessibilityElement = false
        self.filterStackView.isAccessibilityElement = true
        self.filterStackView.accessibilityTraits = .button
        self.filterStackView.accessibilityLabel = localized("generic_button_filters")
        self.accessibilityElements = [movementsLabel as Any, filterStackView as Any]
    }
        
    @objc func didTapOnDownloadMovements(_ sender: Any) {
        self.stateSubject.send(.download)
    }
    
    @objc func didTapOnFilterMovements(_ sender: Any) {
        self.stateSubject.send(.filter)
    }
}
