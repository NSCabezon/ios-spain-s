//
//  ConsultFormatPaymentListDTO.swift
//  Bills
//
//  Created by Cristobal Ramos Laina on 19/05/2020.
//
import Fuzi
import Foundation

public class ConsultTaxCollectionFormatsDTO {
    public let fields: [TaxCollectionFieldDTO]
    public let signature: SignatureDTO
    public let systemDate: Date
    
    public init(fields: [TaxCollectionFieldDTO], signature: SignatureDTO, systemDate: Date) {
        self.fields = fields
        self.signature = signature
        self.systemDate = systemDate
    }
}
