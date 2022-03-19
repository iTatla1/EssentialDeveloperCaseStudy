//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Muhammad Usman Tatla on 19/03/2022.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    FeedImage(id: UUID(), description: "any-description", location: "any-location", url: URL(string: "http://www.any-url.com")!)
}

func uniqueImageFeed() -> (models: [FeedImage], locals: [LocalFeedImage]) {
    let feed = [uniqueImage(),uniqueImage(),uniqueImage()]
    let localFeedImages = feed.map{LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)}
    return (feed, localFeedImages)
}


extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
