//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Muhammad Usman Tatla on 19/03/2022.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://www.anyurl.com")!
}
