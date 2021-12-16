//
//  CacheFeedUseCase.swift
//  EssentialFeedTests
//
//  Created by Muhammad Usman Tatla on 12/16/21.
//

import XCTest
import EssentialFeed

class FeedStore {
    var deleteCachedFeedCellCount = 0
    
    func deleteCachedFeed() {
        deleteCachedFeedCellCount += 1
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]){
        store.deleteCachedFeed()
    }
}

class CacheFeedUseCase: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCachedFeedCellCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem(),uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCellCount, 1)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        trackForMemoryLeak(store,file: file, line: line)
        trackForMemoryLeak(sut,file: file, line: line)
        return(sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        FeedItem(id: UUID(), description: "any-description", location: "any-location", imageURL: URL(string: "http://www.any-url.com")!)
    }
    
}
