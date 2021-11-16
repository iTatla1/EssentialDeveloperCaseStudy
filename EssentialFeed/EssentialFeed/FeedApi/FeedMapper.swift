//
//  FeedMapper.swift
//  EssentialFeed
//
//  Created by Muhammad Usman Tatla on 11/16/21.
//

import Foundation

internal final class FeedItemMapper {
    
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
    
    private static var OK_200: Int {return 200}
        
    internal static func map(_ data: Data, _ respone: HTTPURLResponse) throws -> [FeedItem] {
        guard respone.statusCode == OK_200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        let root = try JSONDecoder().decode(Root.self, from: data)
        return root.items.map{$0.item}
    }
}

