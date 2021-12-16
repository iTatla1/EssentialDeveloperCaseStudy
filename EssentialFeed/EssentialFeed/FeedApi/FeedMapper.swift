//
//  FeedMapper.swift
//  EssentialFeed
//
//  Created by Muhammad Usman Tatla on 11/16/21.
//

import Foundation

internal final class FeedItemMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }


    
    private static var OK_200: Int {return 200}
    
    internal static func map(_ data: Data, from response: HTTPURLResponse) throws ->  [RemoteFeedItem] {
        guard response.statusCode == OK_200, let root =  try? JSONDecoder().decode(Root.self, from: data) else {
             throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}

struct RemoteFeedItem: Decodable  {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
