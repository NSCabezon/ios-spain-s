//
//  OneInputSelect.swift
//  Models
//
//  Created by Daniel Gómez Barroso on 21/9/21.
//

public enum OneInputSelectType {
    case picker
    case bottomSheet(view: UIView, type: BottomSheetSize = .top)
    
    public enum BottomSheetSize {
        case top, auto
    }
}

public final class OneInputSelectViewModel {
    public let type: OneInputSelectType
    public let status: OneStatus
    public let infoLabelKey: String?
    public let pickerData: [String]
    public var selectedInput: Int?
    public let placeholderKey: String?
    public let warningKey: String?
    public let accessibilitySuffix: String?

    public init(type: OneInputSelectType = .picker,
                status: OneStatus = .inactive,
                infoLabelKey: String? = nil,
                pickerData: [String],
                selectedInput: Int? = nil,
                placeholderKey: String? = nil,
                warningKey: String? = nil,
                accessibilitySuffix: String? = nil) {
        self.type = type
        self.selectedInput = selectedInput
        self.status = status
        self.infoLabelKey = infoLabelKey
        self.pickerData = pickerData
        self.placeholderKey = placeholderKey
        self.warningKey = warningKey
        self.accessibilitySuffix = accessibilitySuffix
    }
    
    public func setSelectedInput(_ index: Int) {
        self.selectedInput = index
    }
}
