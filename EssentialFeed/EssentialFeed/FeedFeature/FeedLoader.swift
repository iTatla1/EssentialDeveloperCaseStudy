//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Muhammad Usman Tatla on 10/16/21.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
