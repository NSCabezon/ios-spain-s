import UIKit
import CoreFoundationLib

enum SelectionViewType {
    case accessoryView
    case listView
}

class PickerController<T: PickerElement>: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDataSource, UITableViewDelegate {
    var selectedValue: T? {
        didSet {
            switch selectionViewType {
            case .accessoryView:
                guard let index = elements.firstIndex(where: { (element) -> Bool in
                    return element == selectedValue
                }) else {
                    return
                }
                (relatedView as? UITextField)?.text = selectedValue?.value
                if pickerView.selectedRow(inComponent: 0) != index {
                    pickerView.selectRow(index, inComponent: 0, animated: false)
                }
            default:
                break
            }
        }
    }
    var onSelection: ((_ selected: T) -> Void)?
    
    private var elements = [T]()
    private var labelPrefix = ""
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.accessibilityIdentifier = AccessibilityOthers.pickerController.rawValue
        return pickerView
    }()
    
    private lazy var tableView: PickerTableView = {
        let tableView = PickerTableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        
        return tableView
    }()
    
    private weak var relatedView: UIView?
    private var selectionViewType: SelectionViewType
    
    required init(elements: [T], labelPrefix: String, relatedView: UIView, selectionViewType: SelectionViewType) {
        self.elements = elements
        self.labelPrefix = labelPrefix
        self.relatedView = relatedView
        self.selectionViewType = selectionViewType
        super.init()
        selectedValue = elements.first
        
        switch selectionViewType {
        case .accessoryView:
            guard let textInput = relatedView as? UITextField else {
                fatalError("Error: no text input view submitted")
            }
            textInput.inputView = pickerView
            textInput.tintColor = .clear
        case .listView:
            makeTable()
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        }
    }
    
    deinit {
        switch selectionViewType {
        case .listView:
            NotificationCenter.default.removeObserver(self)
        default:
            break
        }
    }
    
    // PICKER DELEGATION
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return elements.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let element = elements[row]
        selectedValue = element
        onSelection?(element)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var element = elements[row]
        element.accessibilityIdentifier = AccessibilityOthers.pickerElement.rawValue + "_\(String(row))"
        return element.value
    }
    
    // TABLE MANIPULATION
    
    let elementCellIdentifier = "ElementCell"
    
    private func makeTable() {
        guard tableView.superview == nil, let relatedView = relatedView else {
            return
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: elementCellIdentifier)
        tableView.related = relatedView
        tableView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(relatedViewTouched(gesture:)))
        relatedView.addGestureRecognizer(tapGesture)
        relatedView.isUserInteractionEnabled = true
    }
    
    @objc
    private func relatedViewTouched(gesture: UITapGestureRecognizer) {
        tableView.collapse(flag: false)
    }
    
    // TABLE DELEGATION
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: elementCellIdentifier)!
        cell.textLabel?.text = elements[indexPath.row].value
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedValue = elements[indexPath.row]
        onSelection?(selectedValue!)
        (tableView as? PickerTableView)?.collapse(flag: true)
    }
    
    @objc
    private func keyboardWillShow() {
        tableView.collapse(flag: true)
    }
}

private class PickerTableView: UITableView {
    var heightConstraint: NSLayoutConstraint!
    var related: UIView? {
        get {
            return _related
        }
        set {
            _related = newValue
            guard let newValue = newValue else {
                return
            }
            
            layer.cornerRadius = newValue.layer.cornerRadius
            cornerRadiusObservation = related?.observe(\UIView.layer.cornerRadius, options: [.new]) { (_, change) in
                if let cornerRadius = change.newValue {
                    self.layer.cornerRadius = cornerRadius
                }
            }
            
            DispatchQueue.main.async {
                let builder = NSLayoutConstraint.Builder()
                    .add(self.topAnchor.constraint(equalTo: newValue.topAnchor))
                    .add(self.leadingAnchor.constraint(equalTo: newValue.leadingAnchor))
                    .add(self.widthAnchor.constraint(equalTo: newValue.widthAnchor))
                
                self.rowHeight = newValue.frame.height
                self.heightConstraint = self.heightAnchor.constraint(equalToConstant: self.rowHeight)
                builder += self.heightConstraint
                
                if !self.installInSuperview(of: newValue) {
                    fatalError("Error: Could not install table view in view hierarchy")
                }
                
                builder.activate()
            }
        }
    }
    
    private var cornerRadiusObservation: NSKeyValueObservation?
    
    private var _related: UIView?
    
    func collapse(flag: Bool) {
        guard let superview = superview else {
            return
        }
        
        let newHeight = flag ? rowHeight : rowHeight * CGFloat(numberOfRows(inSection: 0))
        guard newHeight != heightConstraint.constant else {
            return
        }
        
        isHidden = false
        heightConstraint.constant = newHeight
        UIView.animate(withDuration: 0.2, animations: { superview.layoutIfNeeded() }, completion: { _ in self.isHidden = flag })
    }
    
    private func installInSuperview(of view: UIView) -> Bool {
        guard let superview = view.superview else {
            return false
        }
        if !enoughSpaceIn(view: superview) {
            return installInSuperview(of: superview)
        }
        superview.addSubview(self)
        return true
    }
    
    private func enoughSpaceIn(view: UIView) -> Bool {
        let estimatedHeight = view.frame.height
        return estimatedHeight >= CGFloat(numberOfRows(inSection: 0)) * rowHeight
    }
}
