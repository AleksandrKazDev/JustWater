//
//  DateProviding.swift
//  JustWater
//
//  Created by сонный on 01.06.2026.
//

import Foundation

protocol DateProviding {
    var now: Date { get }
}

struct SystemDateProvider: DateProviding {
    var now: Date {
        Date()
    }
}
