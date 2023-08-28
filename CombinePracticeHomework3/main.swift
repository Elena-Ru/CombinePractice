//
//  main.swift
//  CombinePracticeHomework3
//
//  Created by Елена Русских on 2023-08-28.
//

import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
let stringEmitter = PassthroughSubject<String, Never>()
let emojiEmitter = PassthroughSubject<String, Never>()
var lastEmittedDate: Date?

stringEmitter
    .sink { value in
        let currentDate = Date()
        
        if let lastEmission = lastEmittedDate, currentDate.timeIntervalSince(lastEmission) > 0.9 {
            emojiEmitter.send("☀️")
        } else {
            emojiEmitter.send("")
        }
        
        lastEmittedDate = currentDate
    }
    .store(in: &subscriptions)

let characterTransformedPublisher = stringEmitter
    .collect(.byTime(DispatchQueue.main, .seconds(0.5)))
    .map { values -> [Character] in
        values.compactMap { value -> Character? in
            if let scalarValue = UInt32(value),
               let unicodeScalar = Unicode.Scalar(scalarValue) {
                return Character(unicodeScalar)
            }
            return nil
        }
    }
    .map { String($0) }
    .eraseToAnyPublisher()

let combinedOutputPublisher = Publishers.Merge(characterTransformedPublisher, emojiEmitter)
    .filter { !$0.isEmpty }
    .eraseToAnyPublisher()

combinedOutputPublisher
    .sink { print($0) }
    .store(in: &subscriptions)

stringEmitter.send("115")
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    stringEmitter.send("36")
}
DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
    stringEmitter.send("test")
}
DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
    stringEmitter.send("65")
}

RunLoop.current.run(until: Date().addingTimeInterval(3))
