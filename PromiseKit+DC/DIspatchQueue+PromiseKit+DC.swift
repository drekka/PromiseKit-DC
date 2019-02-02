//
//  File.swift
//  PromiseKit+DC
//
//  Created by Derek Clarkson on 2/2/19.
//  Copyright © 2019 Derek Clarkson. All rights reserved.
//

import PromiseKit

public extension DispatchQueue {

    /// Asynchronously executes the provided closure on a dispatch queue.
    ///
    /// This differs slightly from the `DispatchQueue.async(...)` in PromiseKit in that the function depends on the
    /// closure signature to determine the correct method to execute rather than passing an additional argument.
    ///
    ///     DispatchQueue.global().async { () -> Int in
    ///         md5(input)
    ///     }.done { md5 in
    ///         //…
    ///     }
    ///
    /// - Parameter body: The closure that resolves this promise.
    /// - Returns: A new `Guarantee` resolved by the result of the provided closure.

    final func asyncGuarantee<T>(group: DispatchGroup? = nil, qos: DispatchQoS = .default, flags: DispatchWorkItemFlags = [], execute body: @escaping () -> T) -> Guarantee<T> {
        let pending = Guarantee<T>.pending()
        async(group: group, qos: qos, flags: flags) {
            pending.resolve(body())
        }
        return pending.guarantee
    }

    /// Asynchronously executes the provided closure on a dispatch queue.
    ///
    /// This version passes a resolver to the closure as per the Guarantee<T> { seal in ... } initializer.
    /// This makes it useful for asyncing Guarantees that don't resolve immediately.
    /// For example, if you code does something on another queue:
    ///
    ///     DispatchQueue.global().async { (seal:(Int) -> Void) in
    ///         Dispatch.main.async {
    ///             seal(md5)
    ///         }
    ///     }.done { md5 in
    ///         //…
    ///     }
    ///
    /// - Parameter body: The closure that resolves this promise.
    /// - Returns: A new `Guarantee` resolved using the seal passed to the provided closure.
    
    final func asyncGuarantee<T>(group: DispatchGroup? = nil, qos: DispatchQoS = .default, flags: DispatchWorkItemFlags = [], resolver body: @escaping (@escaping(T) -> Void) -> Void) -> Guarantee<T> {
        return Guarantee<T> { seal in
            async(group: group, qos: qos, flags: flags) {
                body(seal)
            }
        }
    }

    /// Asynchronously executes the provided closure on a dispatch queue.
    ///
    /// This differs slightly from the `DispatchQueue.async(...)` in PromiseKit in that the function depends on the
    /// closure signature to determine the correct method to execute rather than passing an additional argument.
    ///
    ///     DispatchQueue.global().async { () -> Int in
    ///         try md5(input)
    ///     }.done { md5 in
    ///         //…
    ///     }
    ///
    /// - Parameter body: The closure that resolves this promise.
    /// - Returns: A new `Promise` resolved by the result of the provided closure.

    final func asyncPromise<T>(group: DispatchGroup? = nil, qos: DispatchQoS = .default, flags: DispatchWorkItemFlags = [], execute body: @escaping () throws -> T) -> Promise<T> {
        let pending = Promise<T>.pending()
        async(group: group, qos: qos, flags: flags) {
            do {
                pending.resolver.fulfill(try body())
            } catch {
                pending.resolver.reject(error)
            }
        }
        return pending.promise
    }

    /// Asynchronously executes the provided closure on a dispatch queue.
    ///
    /// This version passes a resolver to the closure as per the Promise<T> { seal in ... } initializer.
    /// This makes it useful for creating promises based on closures
    /// that don't resolve immediately when called.
    ///
    /// For example, if your code passes on to another queue:
    ///
    ///     DispatchQueue.global().async { (seal: Resolver<Int>) in
    ///         DispatchQueue.main.async {
    ///             seal(md5)
    ///         }
    ///     }.done { md5 in
    ///         //…
    ///     }
    ///
    /// - Parameter body: The closure that resolves this promise.
    /// - Returns: A new promise resolved using the seal passed to the provided closure.

    final func asyncPromise<T>(group: DispatchGroup? = nil, qos: DispatchQoS = .default, flags: DispatchWorkItemFlags = [], resolver body: @escaping (Resolver<T>) -> Void) -> Promise<T> {
        let pending = Promise<T>.pending()
        async(group: group, qos: qos, flags: flags) {
            body(pending.resolver)
        }
        return pending.promise
    }
}
