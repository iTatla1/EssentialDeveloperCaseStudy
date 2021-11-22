//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Muhammad Usman Tatla on 11/16/21.
//

import Foundation

public typealias HTTPClientResult = Result<(Data,HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
