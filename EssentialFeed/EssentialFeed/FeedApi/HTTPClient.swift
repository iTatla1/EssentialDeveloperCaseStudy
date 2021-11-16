//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Muhammad Usman Tatla on 11/16/21.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<(Data,HTTPURLResponse), Error>) -> Void)
}
