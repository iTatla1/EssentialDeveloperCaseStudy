//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Muhammad Usman Tatla on 11/11/21.
//

import XCTest

class HTTPClient {
    static var shared = HTTPClient()
    
    func get(from url: URL) {
    }
}

class HTTPClientSpy: HTTPClient {
   
    var requestedURL: URL?
    
    override func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "http://a-url.com")!)
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromClient() {
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let client = HTTPClientSpy()
        HTTPClient.shared = client
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
   
}
