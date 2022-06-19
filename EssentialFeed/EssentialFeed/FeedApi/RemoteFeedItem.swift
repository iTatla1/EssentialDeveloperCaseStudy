//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Muhammad Usman Tatla on 12/16/21.
//

import Foundation

struct RemoteFeedItem: Decodable  {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
