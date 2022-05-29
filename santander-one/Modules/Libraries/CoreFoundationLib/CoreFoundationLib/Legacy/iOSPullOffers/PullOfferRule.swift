//
//  PullOfferRule.swift
//  IOS-Pull-Offers
//
//  Created by Carlos Pérez Pérez on 4/6/18.
//  Copyright © 2018 Carlos Pérez Pérez. All rights reserved.
//

protocol PullOfferRule {
    var id: String {get set}
    var desc: String {get set}
    var expression: String {get set}
}
