//
//  File.swift
//  Assets
//
//  Created by Jose Carlos Estela Anguita on 25/09/2019.
//  Copyright © 2019 Jose Carlos Estela Anguita. All rights reserved.
//

import UIKit

public final class Assets {
    
    public static func image(named name: String) -> UIImage? {
        return UIImage(named: name, in: Bundle(for: Assets.self), compatibleWith: nil) ?? self.getLocalCountryImage(named: name)
    }
    
    private static func getLocalCountryImage(named name: String) -> UIImage? {
        return UIImage(named: name)
    }
}
