//
//  Commons.swift
//  Commons
//
// Created by Juan Carlos López Robles on 2/19/20.

import Foundation
public enum ViewState<T> {
    case loading
    case empty
    case filled(T)
}
