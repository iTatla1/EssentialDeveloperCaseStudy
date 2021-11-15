//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Muhammad Usman Tatla on 10/16/21.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
