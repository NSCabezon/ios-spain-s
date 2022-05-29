//
//  ViewController.swift
//  SelfSignedCertificate
//
//  Created by Israel Marcos Álvarez Mesa on 07/23/2021.
//  Copyright (c) 2021 Israel Marcos Álvarez Mesa. All rights reserved.
//

import UIKit
import os
import SelfSignedCertificate

class ViewController: UIViewController {
    
    let label = "MyExampleAppSecIdentity"
    let subjectCommonName = "Santander"
    let subjectOrganizationName = "Santander Bank Polska S.A."
    let contryName = "PL"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        secIdentityProcess()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func secIdentityProcess() {
        do {
            let createdSecIdentity = try SecIdentity.createSecIdentity(subjectCommonName: self.subjectCommonName, subjectOrganizationName: self.subjectOrganizationName, contryName: self.contryName)
            let isUpdatedSecIdentity = try SecIdentity.updateSecIdentity(secIdentity: createdSecIdentity, label: label)
            let secIdentity = try SecIdentity.getSecIdentity(label: self.label)
            let secCertificate = try SecIdentity.getSecCertificateFromSecIdentity(secIdentity: secIdentity)
            let encodedCertificate = try SecIdentity.encodeCertificate(secCertificate: secCertificate)
            let privateKey = try SecIdentity.getPrivateKeyFromSecIdentity(secIdentity: secIdentity)
            let publicKey = try SecIdentity.getPublicKeyFromSecIdentity(secIdentity: secIdentity)
            let isDeletedSecIdentity = try SecIdentity.deleteSecIdentity(label: self.label)
            
            return
        } catch {
            return
        }
    }
}

