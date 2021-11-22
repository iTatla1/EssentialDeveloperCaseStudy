//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Muhammad Usman Tatla on 11/22/21.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void){
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL(){
        let url = URL(string: "http://www.anyurl.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        sut.get(from: url) {_ in}
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://www.anyurl.com")!
        let error = NSError(domain:"any error", code: 1)
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, error: error)
        
        let expectation = expectation(description: "Wait for async operation")
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, error)
            default:
                XCTFail("Expected error: \(error), got \(result) else instead")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK:- Helpers
    private class URLSessionSpy: URLSession {
        
        private var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            let task: URLSessionDataTask
            let error: Error?
        }
        
        
        func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            guard let stub = stubs[url] else {
                fatalError("Could not find stub for given url")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
        
        private class FakeURLSessionDataTask: URLSessionDataTask{
            override func resume() {}
        }
        
        
    }
    
    private class URLSessionDataTaskSpy: URLSessionDataTask{
        var resumeCallCount = 0
        
        override func resume() {
            resumeCallCount += 1
        }
    }
}
