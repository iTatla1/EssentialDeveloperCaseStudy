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
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from:  url) { result in
            switch result {
            case let .success((data, response)) :
                if let items = try? FeedItemMapper.map(data, response)  {
                    completion(.success(items))
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

private final class FeedItemMapper {
    
    private struct Root: Decodable {
        let items: [item]
    }

    private struct item: Decodable  {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem(id: id, description: description, location: location, imageURL: image)
        }
    }
    
    static var OK_200: Int {return 200}
        
    static func map(_ data: Data, _ respone: HTTPURLResponse) throws -> [FeedItem] {
        guard respone.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map{$0.item}
    }
}

