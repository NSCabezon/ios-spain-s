//
//  ValidateAccountTransferRepresentable.swift
//  CoreFoundationLib
//
//  Created by David Gálvez Alonso on 19/08/2021.
//


public protocol ValidateAccountTransferRepresentable {
    var transferNationalRepresentable: TransferNationalRepresentable? { get }
    var errorCode: String? { get }
}
