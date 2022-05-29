//
//  PDFCoordinatorLauncher.swift
//  PdfCommons
//
//  Created by alvola on 24/06/2021.
//

import CoreFoundationLib

public protocol PDFCoordinatorLauncher {
    func openPDF(_ data: Data, title: String, source: PdfSource)
}
