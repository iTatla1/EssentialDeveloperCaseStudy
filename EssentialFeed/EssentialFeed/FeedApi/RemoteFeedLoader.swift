//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Muhammad Usman Tatla on 11/11/21.
//

import Foundation

public final class RemoteFeedLoader {
    
    public typealias Result = Swift.Result<[FeedItem], RemoteFeedLoader.Error>
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (LoadFeedResult) -> Void) {
        client.get(from:  url) {[weak self] result in
            guard self != nil else {return}
            switch result {
            case let .success((data, response)) :
                completion(FeedItemMapper.map(data, from: response))
               
            case .failure( _):
                completion(.failure(Error.connectivity))
            }
        }
    }
   
}
