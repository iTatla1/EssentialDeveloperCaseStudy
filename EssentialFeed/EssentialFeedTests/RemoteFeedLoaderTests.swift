//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Muhammad Usman Tatla on 11/11/21.
//

import XCTest

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
   
    var requestedURL: URL?
    
    func get(from url: URL) {
        requestedURL = url
    }
}

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from:  url)
    }
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromClient() {
        let url =  URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(url: url, client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL(){
        let url =  URL(string: "http://a-url.com")!
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        XCTAssertEqual(client.requestedURL, url)
    }
    
    
    func anyURL() -> URL {
        URL(string: "http://a-url.com")!
    }
   
}
