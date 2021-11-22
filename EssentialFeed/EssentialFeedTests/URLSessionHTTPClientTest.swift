//
//  URLSessionHTTPClientTest.swift
//  EssentialFeedTests
//
//  Created by Muhammad Usman Tatla on 11/22/21.
//

import XCTest
import EssentialFeed

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

class URLSessionHTTPClient {
    private let session: HTTPSession
    
    init(session: HTTPSession) {
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

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClientTest: XCTestCase {
    
    func test_getFromURL_resumesDataTaskWithURL(){
        let url = URL(string: "http://www.anyurl.com")!
        let session = HTTPSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        let task = URLSessionDataTaskSpy()
        session.stub(url: url, task: task)
        
        sut.get(from: url) {_ in}
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "http://www.anyurl.com")!
        let error = NSError(domain:"any error", code: 1)
        let session = HTTPSessionSpy()
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
    private class HTTPSessionSpy: HTTPSession {
        
        private var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            let task: HTTPSessionTask
            let error: Error?
        }
        
        
        func stub(url: URL, task: HTTPSessionTask = FakeURLSessionDataTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            guard let stub = stubs[url] else {
                fatalError("Could not find stub for given url")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
        
        private class FakeURLSessionDataTask: HTTPSessionTask{
            func resume() {}
        }
        
        
    }
    
    private class URLSessionDataTaskSpy: HTTPSessionTask{
        var resumeCallCount = 0
        
        func resume() {
            resumeCallCount += 1
        }
    }
}
