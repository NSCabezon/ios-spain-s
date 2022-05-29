//
//  OneInputRegularViewModel.swift
//  Models
//
//  Created by David Gálvez Alonso on 23/9/21.
//

public final class OneInputRegularViewModel {
    public let status: Status
    public let text: String?
    public let placeholder: String?
    public let searchAction: (() -> Void)?
    public let resetText: Bool
    public let alignment: Alignment?
    public let textSize: TextSize?
    public let textContentType: TextContentType?
    public let accessibilitySuffix: String?

    public init(status: Status,
                text: String? = nil,
                placeholder: String? = nil,
                searchAction: (() -> Void)? = nil,
                resetText: Bool = false,
                alignment: Alignment? = nil,
                textSize: TextSize? = nil,
                textContentType: TextContentType? = nil,
                accessibilitySuffix: String? = nil) {
        self.status = status
        self.text = text
        self.placeholder = placeholder
        self.searchAction = searchAction
        self.resetText = resetText
        self.alignment = alignment
        self.textSize = textSize
        self.textContentType = textContentType
        self.accessibilitySuffix = accessibilitySuffix
    }
    
    public enum Status {
        case inactive
        case focused
        case activated
        case disabled
        case error
    }
    
    public enum Alignment {
        case leading
        case center
    }
    
    public enum TextSize {
        case large
    }
    
    public enum TextContentType {
        case otp
    }
}
