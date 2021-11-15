//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Muhammad Usman Tatla on 11/11/21.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (Result<(Data,HTTPURLResponse), Error>) -> Void)
}

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
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from:  url) { result in
            switch result {
            case let .success((data, response)) :
                if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data)  {
                    completion(.success(root.items))
                }
                else {
                    completion(.failure(.invalidData))
                }
               
            case .failure( _):
                completion(.failure(.connectivity))
            }
        }
    }
}

private struct Root: Decodable {
    let items: [FeedItem]
}
