//
//  LoadFeedFromCacheUseCase.swift
//  EssentialFeedTests
//
//  Created by Muhammad Usman Tatla on 13/03/2022.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCase: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in}
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut: sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()

        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrievalWithEmptyCache()
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})

        let feed = uniqueImageFeed()

        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.locals, timestamp: sevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})

        let feed = uniqueImageFeed()

        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.locals, timestamp: moreThanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversCachedImagesOnLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})

        let feed = uniqueImageFeed()

        expect(sut: sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.locals, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_hasNoSideEffectOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})

        let feed = uniqueImageFeed()

        sut.load { _ in }
        store.completeRetrieval(with: feed.locals, timestamp: lessThanSevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})

        let feed = uniqueImageFeed()

        sut.load { _ in }
        store.completeRetrieval(with: feed.locals, timestamp: sevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectOnMoreThabSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let moreThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(days: -1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})

        let feed = uniqueImageFeed()

        sut.load { _ in }
        store.completeRetrieval(with: feed.locals, timestamp: moreThanSevenDaysOldTimestamp)

        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDelieverResultAfterSUTInstanceHasBeenDeAllocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        
        var receivedResults = [LocalFeedLoader.LoadResult]()
        sut?.load {receivedResults.append($0)}
        
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(receivedResults.isEmpty, "Expect no result after sut instance has been deallocated.")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init ,file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeak(store,file: file, line: line)
        trackForMemoryLeak(sut,file: file, line: line)
        return(sut, store)
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void ,file: StaticString = #filePath, line: UInt = #line) {
        let exectation = expectation(description: "Waiting for load completion")

        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            exectation.fulfill()
        }
        action()
        wait(for: [exectation], timeout: 1.0)
    }
}
