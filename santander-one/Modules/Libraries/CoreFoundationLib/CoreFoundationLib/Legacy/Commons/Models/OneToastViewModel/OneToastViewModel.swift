//
//  OneToastViewModel.swift
//  CoreFoundationLib
//
//  Created by Angel Abad Perez on 31/3/22.
//

public struct OneToastViewModel {
    public let leftIconKey: String
    public let titleKey: String?
    public let subtitleKey: String
    public let linkKey: String?
    public let type: OneToastViewType
    public let position: OneToastViewPosition
    public let duration: OneToastViewDuration
    
    public init(leftIconKey: String,
                titleKey: String?,
                subtitleKey: String,
                linkKey: String?,
                type: OneToastViewType,
                position: OneToastViewPosition,
                duration: OneToastViewDuration) {
        self.leftIconKey = leftIconKey
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.linkKey = linkKey
        self.type = type
        self.position = position
        self.duration = duration
    }
    
    public enum OneToastViewType {
        case large
        case small
        
        public var leftIconHeight: CGFloat {
            switch self {
            case .large: return 48.0
            case .small: return 32.0
            }
        }
        
        public var isTitleHidden: Bool {
            return self == .small ? true : false
        }
    }
    
    public enum OneToastViewPosition {
        case top
        case bottom
    }
    
    public enum OneToastViewDuration {
        case infinite
        case custom(TimeInterval)
    }
}
