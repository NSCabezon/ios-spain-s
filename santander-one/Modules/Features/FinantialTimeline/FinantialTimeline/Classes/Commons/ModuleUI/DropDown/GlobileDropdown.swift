//
//  GlobileDropdown.swift
//  FinantialTimeline
//
//  Created by Hernán Villamil on 22/9/21.
//

import UIKit

protocol GlobileDropDownDelegate: class {
    func dropDownSelected <T>(_ item: GlobileDropdownData<T>, _ sender: GlobileDropdown<T>)
    func dropdownExpanded <T>(_ sender: GlobileDropdown<T>)
    func dropdownCompressed <T>(_ sender: GlobileDropdown<T>)
}

extension GlobileDropDownDelegate {
    func dropdownExpanded <T>(_ sender: GlobileDropdown<T>){}
    func dropdownCompressed <T>(_ sender: GlobileDropdown<T>){}
}

enum SantanderDropDownErrorState {
    case error
    case normal
}

enum SantanderDropDownColorTheme {
    case white
    case sky
}

class GlobileDropdown<T>: UIView, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Vars
    var items: [GlobileDropdownData<T>]?
    var theme: SantanderDropDownColorTheme = .white {
        didSet {
            dropButton.theme = theme
        }
    }
    var openclose = false
    private let dropButton = GlobileDropdownButton()
    private let tableView = SantanderDropDownTableView()
    /// The tint color to apply to the checkbox button.
    var color: GlobileDropDownTintColor = .red
    var dropDownDelegate: GlobileDropDownDelegate?
    var itemSelected: Int? = 0 {
        didSet {
            if  self.itemSelected! < tableView.numberOfRows(inSection: 0) {
                tableView.selectRow(at: IndexPath(row: self.itemSelected!, section: 0) , animated: false, scrollPosition: .middle)
                dropButton.setPlaceholderText(text: items![self.itemSelected!].label)
                dropDownDelegate?.dropDownSelected(items![self.itemSelected!], self)
            }
        }
    }
    private var tableViewheightConstraint: NSLayoutConstraint?
    
    var hintMessage: String {
        get {
            return "Select an option..."
        }
        set {
            dropButton.labelView.text = newValue
        }
    }
    
    var floatingMessage: String {
        get {
            return " "
        }
        set {
            dropButton.floatingLabel.text = newValue
        }
    }
    
    //MARK: Bottom line Separator & Label
    fileprivate lazy var bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .bostonRed
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    fileprivate lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = errorMessage
        label.font = .santanderText(type: .regular, with: 14)
        label.textColor = .bostonRed
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()


    // MARK: - Overrides
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        //Put here your visual code in real time.
    }

    // MARK: - Custom setup view
    private func setup() {

        // General
        translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self

        // Subviews
        addSubview(dropButton)
        addSubview(bottomLine)
        addSubview(bottomLabel)
        addSubview(tableView)

        //Button target
        dropButton.addTarget(self, action: #selector(GlobileDropdown.pressButton), for: .touchUpInside)

        // Layout Constraints
        dropButton.translatesAutoresizingMaskIntoConstraints = false

        // Button
        NSLayoutConstraint.activate([
            dropButton.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
            dropButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0),
            dropButton.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0),
           dropButton.heightAnchor.constraint(equalToConstant: 49.0)
            ])

        // Bottomline
        NSLayoutConstraint.activate([
            bottomLine.topAnchor.constraint(equalTo: dropButton.bottomAnchor, constant: 0.0),
            bottomLine.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0),
            bottomLine.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0),
            bottomLine.heightAnchor.constraint(equalToConstant: 1.0)
            ])

        // Bottom label
        NSLayoutConstraint.activate([
            bottomLabel.topAnchor.constraint(equalTo: bottomLine.bottomAnchor, constant: 3.0),
            bottomLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 0.0),
            bottomLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0.0),
            ])

        // Tableview
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: dropButton.bottomAnchor),
            tableView.leftAnchor.constraint(equalTo: leftAnchor),
            tableView.rightAnchor.constraint(equalTo: rightAnchor),
            bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 0.0),
            ])
        tableViewheightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0.0)
        tableViewheightConstraint?.isActive = true
    }

    // MARK: - Show / Hide TableView
     func show() {

        var tableHeight = 47 * 4
        let itemsCount = self.items?.count ?? 0
        if (itemsCount < 4){
            tableHeight = itemsCount * 47
        }
        
        if #available(iOS 10.0, *) {
            UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8) {
                self.tableViewheightConstraint?.constant = CGFloat(tableHeight)
                self.layoutSubviews()
                }.startAnimation()
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableViewheightConstraint?.constant = CGFloat(tableHeight)
                self.layoutSubviews()
            })
        }

        dropButton.rotateUpArrow()
        dropDownDelegate?.dropdownExpanded(self)
    }

     func hide() {
        if #available(iOS 10.0, *) {
            UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8) {
                self.tableViewheightConstraint?.constant = 0.0
                self.tableView.bounds.origin.y = 0.0
                self.layoutSubviews()
                }.startAnimation()
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.tableViewheightConstraint?.constant = 0.0
                self.tableView.bounds.origin.y = 0.0
                self.layoutSubviews()
            })
        }
        dropButton.rotateDownArrow()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "dropcell", for: indexPath) as! GlobileDropdownCell
        cell.textLabel?.text = items![indexPath.row].label
        cell.color = self.color
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dropButton.setPlaceholderText(text: items![indexPath.row].label)
        dropDownDelegate?.dropDownSelected(items![indexPath.row], self)
        pressButton()
    }

    //Button Target function
    @objc func pressButton() {
        if !openclose {
            show()
            openclose = !openclose
        } else {
            hide()
            openclose = !openclose
        }
    }

    private var message = ""
    var errorMessage: String {
        get {
            if (message.isEmpty){
                return "Select an option before going on"
            } else {
                return message
            }
        }
        set {
            message = "Error! " + newValue
            bottomLabel.text = message
        }
    }
    
    func errorState(state: SantanderDropDownErrorState) {
        switch state {
        case .error:
            bottomLine.isHidden = false
            bottomLabel.isHidden = false
        case .normal:
            bottomLine.isHidden = true
            bottomLabel.isHidden = true

        }
    }
}
