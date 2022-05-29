import UIKit
import CoreFoundationLib

public protocol DropdownViewDisplayedDelegate: AnyObject {
    func isDropdownViewDisplayed(_ isDisplayed: Bool)
}

public class DropdownView<T: Equatable & DropdownElement>: UIView, UITableViewDelegate, UITableViewDataSource {
    
    private lazy var textsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 0
        stack.addArrangedSubview(selectionTitleLabel)
        stack.addArrangedSubview(selectionLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var selectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.style.titleFont
        label.textColor = self.style.titleColor
        label.clipsToBounds = false
        return label
    }()
    
    public lazy var selectionLabel: UILabel = {
        let label = UILabel()
        label.font = self.style.valueFont
        label.textColor = self.style.valueColor
        label.clipsToBounds = false
        return label
    }()
    
    private lazy var separator: UIView = {
        let separator = UIView()
        separator.backgroundColor = self.style.separatorColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        return separator
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: Assets.image(named: "icnArrowDownWhite")?.withRenderingMode(.alwaysTemplate))
        imageView.tintColor = self.style.iconColor
        imageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = true
        tableView.showsHorizontalScrollIndicator = false
        tableView.isUserInteractionEnabled = true
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var curtain: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let defaultCellHeight: CGFloat = 44.0
    private var displayMode: DropdownDisplayMode = .defaultSize
    private var displayDirection: DropdownDirection = .downElseUp
    /// Direction where the dropdown is being displayed right now.
    private var displayedDirection: DropdownDirection?
    private var elements: [T] = []
    private var selectedElement: T?
    private let cornerRadius: CGFloat = 5.0

    public var style: DropdownStyle = .standardLisboa() {
        didSet {
            self.selectionTitleLabel.textColor = self.style.titleColor
            self.selectionLabel.textColor = self.style.valueColor
            self.arrowImageView.tintColor = self.style.iconColor
            self.backgroundColor = self.style.backgroundColor
            self.separator.backgroundColor = self.style.separatorColor
            self.selectionTitleLabel.font = self.style.titleFont
            self.selectionLabel.font = self.style.valueFont
            self.setConstraints()
        }
    }
    public var isDisplayed: Bool = false
    public weak var delegate: DropdownDelegate?
    public weak var selectorDelegate: DropdownViewDisplayedDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }
    
    public func configure(_ configuration: DropdownConfiguration<T>) {
        if configuration.title.isEmpty {
            self.selectionTitleLabel.isHidden = true
        } else {
            self.selectionTitleLabel.text = configuration.title
        }
        self.elements = configuration.elements
        if configuration.firstElementDefaultSelected == true {
            self.selectedElement = configuration.elements.first
            self.selectionLabel.text = configuration.elements.first?.name
        }
        self.displayMode = configuration.displayMode
        self.displayDirection = configuration.direction
    }
    
    public func selectElement(_ element: T) {
        self.selectedElement = element
        self.selectionLabel.text = element.name
    }
    
    public func hideArrow(_ hide: Bool) {
        self.arrowImageView.isHidden = hide
        self.separator.isHidden = hide
    }
    
    // MARK: - View configuration
    
    private func initView() {
        self.backgroundColor = self.style.backgroundColor
        self.addSubview(textsStackView)
        self.addSubview(separator)
        self.addSubview(arrowImageView)
        self.setConstraints()
        
        let toggleGesture = UITapGestureRecognizer(target: self, action: #selector(toogle))
        self.addGestureRecognizer(toggleGesture)
        self.accessibilityIdentifier = "btnDropdown"
    }
    
    private func configureSafeCurtain(in container: UIView) {
        curtain.frame = CGRect(origin: .zero, size: container.frame.size)
        curtain.isHidden = false
        container.addSubview(curtain)
        container.bringSubviewToFront(curtain)
        container.bringSubviewToFront(self.tableView)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(toogle))
        curtain.addGestureRecognizer(gesture)
    }
    
    // MARK: - Constraints
    
    private func setConstraints() {
        switch self.style.type {
        case .trips:
            setTripsConstraints()
        case .standardLisboa:
            setStandarLisboaConstraints()
        }
    }
    
    private func setStandarLisboaConstraints() {
        self.heightAnchor.constraint(equalToConstant: 48).isActive = true
        textsStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 3).isActive = true
        textsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -3).isActive = true
        textsStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        textsStackView.rightAnchor.constraint(equalTo: separator.leftAnchor, constant: -10).isActive = true
        separator.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        separator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        separator.rightAnchor.constraint(equalTo: arrowImageView.leftAnchor, constant: -5).isActive = true
        arrowImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        arrowImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8).isActive = true
        arrowImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -6).isActive = true
    }
    
    private func setTripsConstraints() {
        textsStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 7).isActive = true
        textsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -9).isActive = true
        textsStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 14).isActive = true
        textsStackView.rightAnchor.constraint(equalTo: separator.leftAnchor, constant: -10).isActive = true
        separator.topAnchor.constraint(equalTo: self.topAnchor, constant: 14).isActive = true
        separator.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -14).isActive = true
        separator.rightAnchor.constraint(equalTo: arrowImageView.leftAnchor, constant: -5).isActive = true
        arrowImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        arrowImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12).isActive = true
        arrowImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -5).isActive = true
    }
    
    // MARK: - Presentation functions
    
    @objc func toogle() {
        guard !self.arrowImageView.isHidden else { return }
        isDisplayed ? hide(): present()
        selectorDelegate?.isDropdownViewDisplayed(isDisplayed)
    }
    
    private func present() {
        guard let container = self.findContainer(forView: self) else { return }
        if !self.tableView.isDescendant(of: container) { container.addSubview(tableView) }
        self.tableView.reloadData()
        
        guard let tableViewHeight = calculateTableViewHeight(to: container) else {
            hide()
            return
        }
        isDisplayed = true
        arrowImageView.image = Assets.image(named: "icnArrowUpWhite")?.withRenderingMode(.alwaysTemplate)
        self.roundCorners(self.cornerRadius)
        configureSafeCurtain(in: container)
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear, animations: {
            self.tableView.frame.size = CGSize(width: self.frame.width, height: tableViewHeight)
        }, completion: { _ in
            self.tableView.flashScrollIndicators()
        })
        self.drawTableViewShadow()
    }
    
    private func hide() {
        isDisplayed = false
        self.curtain.isHidden = true
        arrowImageView.image = Assets.image(named: "icnArrowDownWhite")?.withRenderingMode(.alwaysTemplate)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear, animations: {
            guard let directionToHide = self.displayedDirection else { return }
            if case .upwards = directionToHide {
                self.hideTableViewShadow()
                let tableViewFrame = self.tableView.frame
                self.tableView.frame = CGRect(x: tableViewFrame.minX, y: tableViewFrame.maxY, width: self.frame.width, height: 0)
            } else if case .downwards = directionToHide {
                self.hideTableViewShadow()
                self.tableView.frame.size = CGSize(width: self.frame.width, height: 0)
            }
        })
    }
    
    private func findContainer(forView view: UIView) -> UIView? {
        if let scrollView = view.next as? UIScrollView {
            return scrollView
        } else if let controller = view.next as? UIViewController {
            return controller.view
        } else if let subview = view.next as? UIView {
            return findContainer(forView: subview)
        } else {
            return nil
        }
    }
    
    // MARK: - Tableview
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return getCell(indexPath)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension DropdownView {
    private func getCell(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = elements[indexPath.row].name
        if elements[indexPath.row] == selectedElement {
            cell.textLabel?.textColor = .lisboaGray
            cell.textLabel?.font = UIFont.santander(family: .text, type: .bold, size: 15)
            cell.backgroundColor = UIColor.lightSanGray.withAlphaComponent(0.15)
        } else {
            cell.textLabel?.textColor = .lisboaGray
            cell.textLabel?.font = UIFont.santander(family: .text, type: .regular, size: 15)
        }
        return cell
    }
    
    private func didSelectRow(_ indexPath: IndexPath) {
        let selectedElement = elements[indexPath.row]
        self.selectedElement = selectedElement
        self.selectionLabel.text = selectedElement.name
        self.tableView.deselectRow(at: indexPath, animated: true)
        self.hide()
        self.selectorDelegate?.isDropdownViewDisplayed(isDisplayed)
        self.delegate?.didSelectOption(element: selectedElement)
    }
}

// MARK: - Frame calculation

extension DropdownView {
    private func calculateTableViewHeight(to container: UIView) -> CGFloat? {
        switch self.displayDirection {
        case .upwards:
            let upwardsHeight = calculateForGoingUpwards(to: container)
            if upwardsHeight >= defaultCellHeight {
                displayedDirection = .upwards
                return -upwardsHeight
            } else {
                return nil
            }
        case .downwards:
            let downwardsHeight = calculateForGoingDownwards(to: container)
            if downwardsHeight >= defaultCellHeight {
                displayedDirection = .downwards
                return downwardsHeight
            } else {
                return nil
            }
        case .upElseDown:
            let upwardsHeight = calculateForGoingUpwards(to: container)
            if upwardsHeight >= defaultCellHeight {
                displayedDirection = .upwards
                return -upwardsHeight
            } else {
                let downwardsHeight = calculateForGoingDownwards(to: container)
                if downwardsHeight >= defaultCellHeight {
                    displayedDirection = .downwards
                    return downwardsHeight
                } else {
                    return nil
                }
            }
        case .downElseUp:
            let downwardsHeight = calculateForGoingDownwards(to: container)
            if downwardsHeight >= defaultCellHeight {
                displayedDirection = .downwards
                return downwardsHeight
            } else {
                let upwardsHeight = calculateForGoingUpwards(to: container)
                if upwardsHeight >= defaultCellHeight {
                    displayedDirection = .upwards
                    return -upwardsHeight
                } else {
                    return nil
                }
            }
        }
    }
    
    private func calculateForGoingUpwards(to container: UIView) -> CGFloat {
        let convertedFrame = convert(self.frame, to: container)
        var tableViewHeight: CGFloat
        
        switch self.displayMode {
        case .growToScreenBounds(let inset):
            tableViewHeight = self.tableView.contentSize.height
            let availableSpace = convertedFrame.minY - inset
            if tableViewHeight > availableSpace {
                let numberOfCellsThatCanBeDisplayed = floor(availableSpace / defaultCellHeight)
                tableViewHeight = numberOfCellsThatCanBeDisplayed * defaultCellHeight
            }
        case .cellsSize(let cellsCount):
            tableViewHeight = CGFloat(min(cellsCount, elements.count)) * defaultCellHeight
        case .defaultSize:
            tableViewHeight = CGFloat(min(4, elements.count)) * defaultCellHeight
        }
        
        self.tableView.frame = CGRect(x: convertedFrame.minX, y: convertedFrame.minY, width: self.frame.width, height: 0)
        return tableViewHeight
    }
    
    private func calculateForGoingDownwards(to container: UIView) -> CGFloat {
        let convertedFrame = convert(self.frame, to: container)
        self.tableView.frame = CGRect(x: convertedFrame.minX, y: convertedFrame.maxY, width: self.frame.width, height: 0)
        
        var tableViewHeight: CGFloat
        
        switch self.displayMode {
        case .growToScreenBounds(let inset):
            tableViewHeight = self.tableView.contentSize.height
            let availableSpace = container.bounds.maxY - convertedFrame.maxY - inset
            if tableViewHeight > availableSpace {
                let numberOfCellsThatCouldBeDisplayed = floor(availableSpace / defaultCellHeight)
                tableViewHeight = numberOfCellsThatCouldBeDisplayed * defaultCellHeight
            }
        case .cellsSize(let cellsCount):
            tableViewHeight = CGFloat(min(cellsCount, elements.count)) * defaultCellHeight
        case .defaultSize:
            tableViewHeight = CGFloat(min(4, elements.count)) * defaultCellHeight
        }
        return tableViewHeight
    }
}

// MARK: - Round corners

extension DropdownView {
    private func roundCorners(_ radius: CGFloat) {
        guard let direction = self.displayedDirection else { return }
        if #available(iOS 11.0, *) {
            self.tableView.clipsToBounds = true
            self.tableView.layer.cornerRadius = radius
            if case .downwards = direction {
                self.tableView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            } else if case .upwards = direction {
                self.tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            }
        } else {
            roundCornersInOlderVersions(radius, displayedDirection: direction)
        }
    }

    private func roundCornersInOlderVersions(_ radius: CGFloat, displayedDirection: DropdownDirection) {
        let path: UIBezierPath
        if case .upwards = displayedDirection {
            path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: radius, height: radius))
        } else {
            path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: radius, height: radius))
        }
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.tableView.layer.mask = mask
    }
    
    func drawTableViewShadow() {
        switch self.style.type {
        case .trips: break
        case .standardLisboa:
            self.addStandardLisboaShadow()
        }
    }
    
    func addStandardLisboaShadow() {
        self.tableView.layer.shadowColor = UIColor.lightSanGray.cgColor
        self.tableView.layer.masksToBounds = false
        self.tableView.layer.shadowOpacity = 0.5
        self.tableView.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.tableView.layer.shadowRadius = 4
    }
    
    func hideTableViewShadow() {
        switch self.style.type {
        case .trips: break
        case .standardLisboa:
            self.tableView.layer.shadowColor = UIColor.clear.cgColor
            self.tableView.layer.masksToBounds = true
        }
    }
}
