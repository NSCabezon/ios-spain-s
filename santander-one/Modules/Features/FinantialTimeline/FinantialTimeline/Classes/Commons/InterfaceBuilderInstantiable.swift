//
//  InterfaceBuilderInstantiable.swift
//  FinantialTimeline
//
//  Created by José Carlos Estela Anguita on 04/07/2019.
//

import Foundation

protocol StoryBoardInstantiable {
    static func storyboardIdentifier() -> String
    static func storyboardBundle() -> Bundle?
    static func storyboardName() -> String
}

extension StoryBoardInstantiable where Self: UIViewController {
    
    static func storyboardIdentifier() -> String {
        return String(describing: self)
    }
    
    static func storyboardBundle() -> Bundle? {
        return .module
    }
    
    static func storyboardName() -> String {
        return "Main"
    }
    
    static func fromStoryBoard() -> Self? {
        return UIStoryboard(
            name: Self.storyboardName(),
            bundle: Self.storyboardBundle()
        ).instantiateViewController(
            withIdentifier: Self.storyboardIdentifier()
        ) as? Self
    }
}

public protocol XibInstantiable {
    static func xibName() -> String
    static func xibBundle() -> Bundle?
}

public extension XibInstantiable where Self: UIViewController {
    
    static func xibName() -> String {
        return String(describing: self)
    }
    
    static func xibBundle() -> Bundle? {
        return .module
    }
    
    static func fromXib() -> Self {
        return Self(
            nibName: Self.xibName(),
            bundle: Self.xibBundle()
        )
    }
}
