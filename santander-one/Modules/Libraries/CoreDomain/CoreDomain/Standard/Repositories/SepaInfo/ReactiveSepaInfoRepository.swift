//
 //  ReactiveSepaInfoRepository.swift
 //  CoreDomain
 //
 //  Created by Carlos Monfort Gómez on 25/4/22.
 //

 import Foundation
 import OpenCombine

 public protocol ReactiveSepaInfoRepository {
     func fetchSepaInfoPublisher() -> AnyPublisher<SepaInfoListRepresentable?, Error>
 }
