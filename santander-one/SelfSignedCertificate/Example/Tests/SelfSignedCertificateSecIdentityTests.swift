//
//  SelfSignedCertificateSecIdentityTests.swift
//  SelfSignedCertificate_Tests
//
//  Created by crodrigueza on 14/10/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import XCTest
import SelfSignedCertificate

class SelfSignedCertificateSecIdentityTests: XCTestCase {
    
    let label = "MyTestSecIdentity"
    let subjectCommonName = "Santander"
    let subjectOrganizationName = "Santander Bank Polska S.A."
    let contryName = "PL"
    
    override func setUpWithError() throws {
        super.setUp()
    }

    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    func testCreateSecIdentity() {
        do {
            let createdSecIdentity = try SecIdentity.createSecIdentity(subjectCommonName: self.subjectCommonName, subjectOrganizationName: self.subjectOrganizationName, contryName: self.contryName)
            let isUpdatedSecIdentity = try SecIdentity.updateSecIdentity(secIdentity: createdSecIdentity, label: self.label)
            
            XCTAssertTrue(isUpdatedSecIdentity)
            
            return
        } catch {
            return
        }
    }
    
    func testUpdateSecIdentity() {
        do {
            let createdSecIdentity = try SecIdentity.createSecIdentity(subjectCommonName: self.subjectCommonName, subjectOrganizationName: self.subjectOrganizationName, contryName: self.contryName)
            let isUpdatedSecIdentity = try SecIdentity.updateSecIdentity(secIdentity: createdSecIdentity, label: self.label)
            
            XCTAssertTrue(isUpdatedSecIdentity)
            
            return
        } catch {
            return
        }
    }
    
    func testGetSecIdentity() {
        do {
            let keychainSecIdentity = try SecIdentity.getSecIdentity(label: self.label)
            
            XCTAssertNotNil(keychainSecIdentity)
            
            return
        } catch {
            return
        }
    }
    
    func testDeleteSecIdentity() {
        do {
            let keychainSecIdentity = try SecIdentity.getSecIdentity(label: self.label)
            let isDeletedSecIdentity = try SecIdentity.deleteSecIdentity(label: self.label)
            
            XCTAssertTrue(isDeletedSecIdentity)
            
            return
        } catch {
            return
        }
    }
    
    func testGetCertificateFromSecIdentity() {
        do {
            let keychainSecIdentity = try SecIdentity.getSecIdentity(label: self.label)
            let secCertificate = try SecIdentity.getSecCertificateFromSecIdentity(secIdentity: keychainSecIdentity)
            
            XCTAssertNotNil(secCertificate)
            
            return
        } catch {
            return
        }
    }
    
    func testEncodeCertificate() {
        do {
            let keychainSecIdentity = try SecIdentity.getSecIdentity(label: self.label)
            let secCertificate = try SecIdentity.getSecCertificateFromSecIdentity(secIdentity: keychainSecIdentity)
            let encodedCertificate = try SecIdentity.encodeCertificate(secCertificate: secCertificate)
            
            XCTAssertNotNil(encodedCertificate)
            
            return
        } catch {
            return
        }

    }
    
    func testGetPrivateKeyFromSecIdentity() {
        do {
            let keychainSecIdentity = try SecIdentity.getSecIdentity(label: self.label)
            let privateKey = try SecIdentity.getPrivateKeyFromSecIdentity(secIdentity: keychainSecIdentity)
            
            XCTAssertNotNil(privateKey)
            
            return
        } catch {
            return
        }
    }
    
    func testGetPublicKeyFromSecIdentity() {
        do {
            let keychainSecIdentity = try SecIdentity.getSecIdentity(label: self.label)
            let publicKey = try SecIdentity.getPublicKeyFromSecIdentity(secIdentity: keychainSecIdentity)
            
            XCTAssertNotNil(publicKey)
            
            return
        } catch {
            return
        }
    }
}
