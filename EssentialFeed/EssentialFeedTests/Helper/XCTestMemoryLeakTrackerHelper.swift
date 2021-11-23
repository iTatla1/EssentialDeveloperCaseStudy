//
//  XCTestMemoryLeakTrackerHelper.swift
//  EssentialFeedTests
//
//  Created by Muhammad Usman Tatla on 11/23/21.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject,  file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
