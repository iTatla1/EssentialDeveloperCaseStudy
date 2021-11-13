//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Muhammad Usman Tatla on 11/11/21.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromClient() {
        
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL(){
        let url =  URL(string: "http://given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load {_ in}
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice(){
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in}
        sut.load { _ in}
        
        XCTAssertEqual(client.requestedURLs, [url, url])
        
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        var capturedError = [RemoteFeedLoader.Error]()
        sut.load {capturedError.append($0)}
        let clientError = NSError(domain: "Test", code: 0, userInfo: nil)
        client.complete(with: clientError)
        
        XCTAssertEqual(capturedError, [.connectivity])
    }
    
    func test_load_deliversErrorOnNon200HTTPError() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        samples.enumerated().forEach { index, code in
            var capturedError = [RemoteFeedLoader.Error]()
            sut.load {capturedError.append($0)}
            client.complete(withStatusCode: code, at: index)
            XCTAssertEqual(capturedError, [.invalidData])
        }
    }
    
    func test_load_deliversErrorOn200HTTPResponseWithInvalidJson() {
        let (sut, client) = makeSUT()
        
            var capturedError = [RemoteFeedLoader.Error]()
            sut.load {capturedError.append($0)}
        let invalidJSON: Data = Data.init("An invalid JSON".utf8)
        client.complete(withStatusCode: 200, data: invalidJSON)
        
        XCTAssertEqual(capturedError, [.invalidData])
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT (url: URL =  URL(string: "http://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        return (RemoteFeedLoader(url: url, client: client), client)
    }
    
    func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs: [URL] { messages.map {$0.url} }
        
        private var messages = [(url: URL, completion: (Result<(Data,HTTPURLResponse), Error>) -> Void)]()
        
        func get(from url: URL, completion: @escaping (Result<(Data,HTTPURLResponse), Error>) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error,at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
        
    }
    
}
