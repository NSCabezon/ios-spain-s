//
//  AtmFilterView.swift
//  Menu
//
//  Created by Juan Carlos López Robles on 10/29/20.
//
import UI
import CoreFoundationLib
import Foundation

protocol AtmFilterViewDelegate: AnyObject {
    func didSelectFilters(_ filters: Set<AtmFilterView.AtmFilter>)
    func removeFilters()
}

final class AtmFilterView: XibView {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var filterLabel: UILabel!
    @IBOutlet private weak var filterImage: UIImageView!
    @IBOutlet private weak var filterContentView: UIView!
    @IBOutlet private weak var filterStackView: UIStackView!
    @IBOutlet weak var showFilterButton: UIButton!
    private weak var delegate: AtmFilterViewDelegate?
    @IBOutlet private weak var topLineView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    func setDelegate(_ delegate: AtmFilterViewDelegate) {
        self.delegate = delegate
    }
    
    func setFilterButton(hidden: Bool) {
        self.filterImage.isHidden = hidden
        self.filterLabel.isHidden = hidden
        self.showFilterButton.isHidden = hidden
    }
    
    @IBAction private func didSelectFilters(_ sender: Any) {
        UIView.animate(withDuration: 0.2,
                       animations: { [unowned self] in
                        self.filterContentView.isHidden = !self.filterContentView.isHidden
                        self.filterContentView.alpha = self.filterContentView.isHidden ? 0 : 1
                        self.layoutIfNeeded()
                       }, completion: { [unowned self] completed in
                        guard completed else { return }
                        guard self.filterContentView.isHidden else { return }
                        self.uncheckFilters()
                        self.delegate?.removeFilters()
                       })
    }
}

extension AtmFilterView {
    enum AtmFilter: Int, CaseIterable {
        case contactless
        case barcode
        case depositCash
        
        var localizedKey: String {
            switch self {
            case .contactless:
                return "atm_label_checkContactless"
            case .barcode:
                return "atm_label_checkBarcode"
            case .depositCash:
                return "atm_label_checkDepositCash"
            }
        }
        
        var accesibilityIdentifier: String {
            switch self {
            case .contactless:
                return "atm_button_checkContactless"
            case .barcode:
                return "atm_button_checkBarcode"
            case .depositCash:
                return "atm_button_checkDepositCash"
            }
        }
    }
}

private extension AtmFilterView {
    func setup() {
        self.setTexts()
        self.setColors()
        self.addAccessibilityIdentifiers()
        self.filterContentView.isHidden = true
        self.filterImage.image = Assets.image(named: "icnFilter")
        AtmFilter.allCases.forEach(addCheckFilters)
    }
    
    func setTexts() {
        self.titleLabel.configureText(withKey: "atm_text_nearbyAtm")
        self.titleLabel.textColor = .lisboaGray
        self.filterLabel.configureText(withKey: "generic_button_filters")
    }
    
    func setColors() {
        self.topLineView.backgroundColor = .lightSkyBlue
        self.filterContentView.backgroundColor = .skyGray
        self.filterLabel.textColor = .darkTorquoise
    }
    
    func addAccessibilityIdentifiers() {
        self.titleLabel.accessibilityIdentifier = AccessibilityAtm.NearestAtms.nearAtmCashierLabel
        self.filterLabel.accessibilityIdentifier = AccessibilityAtm.NearestAtms.filter
        self.filterContentView.accessibilityIdentifier = AccessibilityAtm.NearestAtms.atmBtnsFilters
        self.showFilterButton.accessibilityIdentifier = AccessibilityAtm.NearestAtms.filterButton
    }
    
    func uncheckFilters() {
        self.filterStackView.arrangedSubviews.forEach({
            ($0 as? UIButton)?.isSelected = false
        })
    }
    
    func addCheckFilters(filter: AtmFilter) {
        let button = self.makeFilterButton(for: filter)
        button.accessibilityIdentifier = filter.accesibilityIdentifier
        self.filterStackView.addArrangedSubview(button)
    }
    
    func makeFilterButton(for filter: AtmFilter) -> UIButton {
        let button = UIButton()
        button.setTitleColor(.lisboaGray, for: .normal)
        button.setTitle(localized(filter.localizedKey), for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setImage(Assets.image(named: "checkboxSelected"), for: .selected)
        button.setImage(Assets.image(named: "checkboxDefault"), for: .normal)
        button.titleLabel?.font = .santander(family: .text, type: .regular, size: 14)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 0)
        button.addTarget(self, action: #selector(didSelectCheck), for: .touchUpInside)
        button.tag = filter.rawValue
        return button
    }
    
    @objc func didSelectCheck(button: UIButton) {
        button.isSelected = !button.isSelected
        let filters = self.getSelectedFilters()
        self.delegate?.didSelectFilters(Set(filters))
    }
    
    func getSelectedFilters() -> [AtmFilterView.AtmFilter] {
        return self.filterStackView
            .arrangedSubviews
            .filter(isSelected)
            .compactMap({ AtmFilter(rawValue: $0.tag) })
    }
    
    func isSelected(_ view: UIView) -> Bool {
        return (view as? UIButton)?.isSelected ?? false
    }
}
