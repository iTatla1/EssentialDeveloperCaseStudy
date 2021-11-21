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
        
        var feed: [FeedItem] {
            items.map{$0.item}
        }
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
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) -> LoadFeedResult {
        guard response.statusCode == OK_200, let root =  try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}

