//
//  Task.swift
//  Assets
//
//  Created by Patrick Quinn-Graham on 5/6/2022.
//
//  Taken from https://www.swiftbysundell.com/articles/delaying-an-async-swift-task/

import Foundation

extension Task where Failure == Error {
  @discardableResult static func delayed(
    byTimeInterval delayInterval: TimeInterval,
    priority: TaskPriority? = nil,
    operation: @escaping @Sendable () async throws -> Success
  ) -> Task {
    Task(priority: priority) {
      let delay = UInt64(delayInterval * 1_000_000_000)
      try await Task<Never, Never>.sleep(nanoseconds: delay)
      return try await operation()
    }
  }
}
