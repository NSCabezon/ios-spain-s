//
//  TimeLineMonthSelector.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 15/07/2019.
//

import Foundation

protocol TimeLineMonthSelectorDelegate: class {
    func didSelectMonth(_ month: Date)
}

class TimeLineMonthSelector: UIView {
    
    private let months: [Date]
    private(set) var selectedMonth: Date?
    private weak var delegate: TimeLineMonthSelectorDelegate?
    private var monthButtons: [Date: UIButton] = [:]
    private var stackView: UIStackView?
    private var actualMonth: Date?
    
    init(months: [Date], delegate: TimeLineMonthSelectorDelegate) {
        self.months = months
        self.delegate = delegate
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectMonth(_ month: Date) -> Bool {
        self.selectedMonth = month
        monthButtons.values.forEach(deselectButton)
        guard let selectedButton = monthButtons.first(where: { $0.key.isSameMonth(than: month) })?.value else { return false }
        selectButton(selectedButton)
        monthButtons[actualMonth ?? Date()]?.setTitleColor(.white, for: .normal)
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let stackView = self.stackView else { return }
        monthButtons.forEach({ $0.value.layer.cornerRadius = stackView.frame.size.height / 2 })
    }
    
    // MARK: - Private
    
    private func selectButton(_ button: UIButton) {
        button.setTitleColor(.darkTorquoise, for: .normal)
        button.titleLabel?.font = .santanderText(type: .bold, with: 12)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.darkTorquoise.cgColor
    }
    
    private func deselectButton(_ button: UIButton) {
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.darkTorquoise, for: .normal)
        button.titleLabel?.font = .santanderText(with: 12)
        button.layer.borderColor = UIColor.clear.cgColor
        monthButtons[actualMonth ?? Date()]?.setTitleColor(.white, for: .normal)
    }
    
    private func setup() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        addSubviewWithAutoLayout(
            stackView,
            topAnchorConstant: .equal(to: 1),
            bottomAnchorConstant: .equal(to: -1),
            leftAnchorConstant: .greaterThanOrEqual(to: 32, priority: .defaultLow),
            rightAnchorConstant: .greaterThanOrEqual(to: -16, priority: .defaultLow)
        )
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        self.stackView = stackView
        months.sorted().forEach(addMonthButton)
        self.backgroundColor = .sky30
    }
    
    private func addMonthButton(_ month: Date) {
        guard let stackView = self.stackView, !monthButtons.keys.contains(where: { $0.isSameDay(than: month) }) else { return }
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        let monthDescription = month
            .string(format: .MMM)
            .replacingOccurrences(of: ".", with: "")
            .uppercased()
        button.setTitle(monthDescription, for: .normal)
        
        button.setTitleColor(.darkTorquoise, for: .normal)
        button.titleLabel?.font = .santanderText(type: .bold, with: 11)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 1)
        if month.isSameMonth(than: TimeLine.dependencies.configuration?.currentDate ?? Date()) {
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.darkTorquoise.cgColor
            button.layer.backgroundColor = UIColor.darkTorquoise.cgColor
            button.setTitleColor(.white, for: .normal)
            self.actualMonth = month
        }
        stackView.addArrangedSubview(button)
        button.addTarget(self, action: #selector(buttonDidTouch(_:)), for: .touchUpInside)
        button.widthAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        button.heightAnchor.constraint(equalTo: stackView.heightAnchor).isActive = true
        monthButtons[month] = button
    }
    
    @IBAction private func buttonDidTouch(_ sender: UIButton) {
        guard let date = monthButtons.first(where: { $0.value == sender })?.key else { return }
        delegate?.didSelectMonth(date)
    }
}
