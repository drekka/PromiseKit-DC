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
        DispatchQueue.main.async(.promise) {
            return 5
            }.done { value in
                result = value
        }
        expect(result).toEventually(equal(5))
    }

    func testPromiseKitAsyncPromise() {
        var result: Int = 0
        DispatchQueue.main.async(.promise) {
            return 5
            }.done { value in
                result = value
            }.catch { error in
                XCTFail("\(error)")
        }
        expect(result).toEventually(equal(5))
    }
}

// MARK: - DC Extensions

// Just to confirm we've not stuffed things up.
class PromiseKitDCTests: XCTestCase {

    // MARK: - Guarantees

    func testAsyncGuarantee() {
        var result: Int = 0
        DispatchQueue.main.asyncGuarantee {
            return 5
            }.done { value in
                result = value
        }
        expect(result).toEventually(equal(5))
    }

    func testAsyncGuaranteeGuarantee() {
        var result: Int = 0
        DispatchQueue.main.asyncGuarantee {
            return Guarantee.value(5)
            }.done { value in
                result = value
        }
        expect(result).toEventually(equal(5))
    }

    func testAsyncSealableGuarantee() {
        var result: Int = 0
        DispatchQueue.main.asyncGuarantee { seal in
            seal(5)
            }.done { value in
                result = value
        }
        expect(result).toEventually(equal(5))
    }

    // MARK: - Promises

    func testAsyncPromise() {
        var result: Int = 0
        DispatchQueue.main.asyncPromise {
            return 5
            }.done { value in
                result = value
            }.catch { error in
                XCTFail("\(error)")
        }
        expect(result).toEventually(equal(5))
    }

    func testAsyncPromisePromise() {
        var result: Int = 0
        DispatchQueue.main.asyncPromise {
            return Promise.value(5)
            }.done { value in
                result = value
            }.catch { error in
                XCTFail("\(error)")
        }
        expect(result).toEventually(equal(5))
    }

    func testAsyncPromisePromiseWithError() {
        var errorThrown = false
        DispatchQueue.main.asyncPromise {
            return Promise<Int>(error: TestError.anError)
            }.done { value in
                XCTFail("Expected to fail")
            }.catch { _ in
                errorThrown = true
        }
        expect(errorThrown).toEventually(beTrue())
    }

    func testAsyncPromiseCatchesError() {
        var errorThrown = false
        DispatchQueue.main.asyncPromise {
            throw TestError.anError
            }.done { value in
                XCTFail("Expected to fail")
            }.catch { _ in
                errorThrown = true
        }
        expect(errorThrown).toEventually(beTrue())
    }

    func testAsyncSealablePromise() {
        var result: Int = 0
        DispatchQueue.main.asyncPromise { seal in
            seal.fulfill(5)
            }.done { value in
                result = value
            }.catch { error in
                XCTFail("\(error)")
        }
        expect(result).toEventually(equal(5))
    }

    func testAsyncSealablePromiseCatchesError() {
        var errorThrown = false
        DispatchQueue.main.asyncPromise { (seal: Resolver<Int>) in
            seal.reject(TestError.anError)
            }.done { value in
                XCTFail("Expected to fail")
            }.catch { _ in
                errorThrown = true
        }
        expect(errorThrown).toEventually(beTrue())
    }

}
