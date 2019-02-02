//
//  PromiseKit_DCTests.swift
//  PromiseKit+DCTests
//
//  Created by Derek Clarkson on 2/2/19.
//  Copyright © 2019 Derek Clarkson. All rights reserved.
//

import XCTest
import PromiseKitDC
import PromiseKit
import Nimble

enum TestError: Error {
    case anError
}

// MARK: - PromiseKit

// Just to confirm we've not stuffed things up.
class PromiseKitTests: XCTestCase {

    func testPromiseKitAsyncGuarantee() {
        var result: Int = 0
        _ = DispatchQueue.main.async(.promise) {
                return 5
            }.done { value in
                result = value
        }
        expect(result).toEventually(equal(5))
    }

    func testPromiseKitAsyncPromise() {
        var result: Int = 0
        _ = DispatchQueue.main.async(.promise) {
            return 5
            }.done { value in
                result = value
            }.catch { error in
                XCTFail("\(error)")
        }
        expect(result).toEventually(equal(5))
    }
}

// MARK: - DC Etensions

// Just to confirm we've not stuffed things up.
class PromiseKitDCTests: XCTestCase {

    func testPromiseKitDCAsyncGuarantee() {
        var result: Int = 0
        _ = DispatchQueue.main.asyncGuarantee {
            return 5
            }.done { value in
                result = value
        }
        expect(result).toEventually(equal(5))
    }

    func testPromiseKitDCAsyncPromise() {
        var result: Int = 0
        _ = DispatchQueue.main.asyncPromise {
            return 5
            }.done { value in
                result = value
            }.catch { error in
                XCTFail("\(error)")
        }
        expect(result).toEventually(equal(5))
    }

    func testPromiseKitDCAsyncPromiseCatchesError() {
        var errorThrown = false
        _ = DispatchQueue.main.asyncPromise {
            throw TestError.anError
            }.done { value in
                XCTFail("Expected to fail")
            }.catch { error in
                errorThrown = true
        }
        expect(errorThrown).toEventually(beTrue())
    }

    func testPromiseKitDCAsyncSealableGuarantee() {
        var result: Int = 0
        _ = DispatchQueue.main.asyncGuarantee { seal in
            seal(5)
            }.done { value in
                result = value
        }
        expect(result).toEventually(equal(5))
    }

    func testPromiseKitDCAsyncSealablePromise() {
        var result: Int = 0
        _ = DispatchQueue.main.asyncPromise { seal in
            seal.fulfill(5)
            }.done { value in
                result = value
            }.catch { error in
                XCTFail("\(error)")
        }
        expect(result).toEventually(equal(5))
    }

    func testPromiseKitDCAsyncSealablePromiseCatchesError() {
        var errorThrown = false
        _ = DispatchQueue.main.asyncPromise { (seal: Resolver<Int>) in
            seal.reject(TestError.anError)
            }.done { value in
                XCTFail("Expected to fail")
            }.catch { error in
                errorThrown = true
        }
        expect(errorThrown).toEventually(beTrue())
    }

}
