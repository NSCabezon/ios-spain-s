//
//  URLLauncher.swift
//  BranchLocator
//
//  Created by Ivan Cabezon on 15/10/2018.
//  Copyright © 2018 Globile. All rights reserved.
//

import Foundation

@objc public protocol URLLauncher: class {
	@objc func canOpen(url: URL) -> Bool
	@objc func open(url: URL)
}
