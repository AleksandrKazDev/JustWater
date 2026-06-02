//
//  HistoryAnalyticsServiceTests.swift
//  JustWaterTests
//
//  Created by сонный on 25.05.2026.
//

import XCTest
@testable import JustWater

final class HistoryAnalyticsServiceTests: XCTestCase {
    
    // MARK: - Day Analytics
    
    func testMakeAnalytics_forDay_returnsDayStatistics() {
        // Arrange
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25,
            hour: 10
        )
        
        let entries = [
            makeEntry(
                amount: 300,
                date: makeDate(year: 2026, month: 5, day: 25, hour: 10),
                drinkType: .water
            ),
            makeEntry(
                amount: 500,
                date: makeDate(year: 2026, month: 5, day: 25, hour: 11),
                drinkType: .coffee
            )
        ]
        
        // Act
        let sut = HistoryAnalyticsService.makeAnalytics(
            period: .day,
            entries: entries,
            dailyGoalProvider: { _ in 2000 },
            referenceDate: referenceDate
        )
        
        // Assert
        XCTAssertEqual(
            sut.period,
            .day
        )
        
        XCTAssertEqual(
            sut.statistics.totalAmount,
            800
        )
        
        XCTAssertEqual(
            sut.statistics.averageAmount,
            400
        )
        
        XCTAssertEqual(
            sut.statistics.entriesCount,
            2
        )
        
        XCTAssertEqual(
            sut.statistics.completionRate,
            0.4,
            accuracy: 0.0001
        )
        
        XCTAssertEqual(
            sut.statistics.goalReachedCount,
            0
        )
        
        XCTAssertEqual(
            sut.statistics.bestAmount,
            800
        )
        
        XCTAssertNil(
            sut.statistics.bestLabel
        )
    }
    
    func testMakeAnalytics_forDay_whenGoalReached_setsGoalReachedCountToOne() {
        // Arrange
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let entries = [
            makeEntry(amount: 1200, date: referenceDate),
            makeEntry(amount: 900, date: referenceDate)
        ]
        
        // Act
        let sut = HistoryAnalyticsService.makeAnalytics(
            period: .day,
            entries: entries,
            dailyGoalProvider: { _ in 2000 },
            referenceDate: referenceDate
        )
        
        // Assert
        XCTAssertEqual(
            sut.statistics.totalAmount,
            2100
        )
        
        XCTAssertEqual(
            sut.statistics.goalReachedCount,
            1
        )
        
        XCTAssertEqual(
            sut.statistics.completionRate,
            1.05,
            accuracy: 0.0001
        )
    }
    
    func testMakeAnalytics_forDay_groupsChartPointsByHour() {
        // Arrange
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let entries = [
            makeEntry(
                amount: 200,
                date: makeDate(year: 2026, month: 5, day: 25, hour: 10)
            ),
            makeEntry(
                amount: 300,
                date: makeDate(year: 2026, month: 5, day: 25, hour: 10)
            ),
            makeEntry(
                amount: 500,
                date: makeDate(year: 2026, month: 5, day: 25, hour: 11)
            )
        ]
        
        // Act
        let sut = HistoryAnalyticsService.makeAnalytics(
            period: .day,
            entries: entries,
            dailyGoalProvider: { _ in 2000 },
            referenceDate: referenceDate
        )
        
        // Assert
        XCTAssertEqual(
            sut.chartPoints.count,
            2
        )
        
        XCTAssertEqual(
            sut.chartPoints.map(\HistoryChartPoint.amount),
            [500, 500]
        )
    }
    
    // MARK: - Week Analytics
    
    func testMakeAnalytics_forWeek_createsSevenChartPoints() {
        // Arrange
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let entries = [
            makeEntry(
                amount: 1000,
                date: referenceDate
            )
        ]
        
        // Act
        let sut = HistoryAnalyticsService.makeAnalytics(
            period: .week,
            entries: entries,
            dailyGoalProvider: { _ in 2000 },
            referenceDate: referenceDate
        )
        
        // Assert
        XCTAssertEqual(
            sut.period,
            .week
        )
        
        XCTAssertEqual(
            sut.chartPoints.count,
            7
        )
        
        XCTAssertEqual(
            sut.statistics.totalAmount,
            1000
        )
        
        XCTAssertEqual(
            sut.statistics.averageAmount,
            1000
        )
        
        XCTAssertEqual(
            sut.statistics.entriesCount,
            7
        )
    }
    
    func testMakeAnalytics_forWeek_countsGoalReachedDays() {
        // Arrange
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let nextDay = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: referenceDate
        )!
        
        let entries = [
            makeEntry(amount: 2100, date: referenceDate),
            makeEntry(amount: 2200, date: nextDay),
            makeEntry(amount: 500, date: nextDay)
        ]
        
        // Act
        let sut = HistoryAnalyticsService.makeAnalytics(
            period: .week,
            entries: entries,
            dailyGoalProvider: { _ in 2000 },
            referenceDate: referenceDate
        )
        
        // Assert
        XCTAssertEqual(
            sut.statistics.goalReachedCount,
            2
        )
        
        XCTAssertEqual(
            sut.statistics.bestAmount,
            2700
        )
    }
    
    func testMakeAnalytics_forWeek_usesGoalForEachSpecificDay() {
        // Arrange
        let may25 = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let may26 = makeDate(
            year: 2026,
            month: 5,
            day: 26
        )
        
        let entries = [
            makeEntry(
                amount: 2100,
                date: may25
            ),
            makeEntry(
                amount: 2100,
                date: may26
            )
        ]
        
        let dailyGoalProvider: (Date) -> Int = { date in
            let day = Calendar.current.component(
                .day,
                from: date
            )
            
            switch day {
            case 25:
                return 2000
                
            case 26:
                return 3000
                
            default:
                return 3000
            }
        }
        
        // Act
        let sut = HistoryAnalyticsService.makeAnalytics(
            period: .week,
            entries: entries,
            dailyGoalProvider: dailyGoalProvider,
            referenceDate: may25
        )
        
        // Assert
        XCTAssertEqual(
            sut.statistics.goalReachedCount,
            1
        )
    }
    
    // MARK: - Month Analytics
    
    func testMakeAnalytics_forMonth_createsChartPointForEachDayInMonth() {
        // Arrange
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 15
        )
        
        // Act
        let sut = HistoryAnalyticsService.makeAnalytics(
            period: .month,
            entries: [],
            dailyGoalProvider: { _ in 2000 },
            referenceDate: referenceDate
        )
        
        // Assert
        XCTAssertEqual(
            sut.period,
            .month
        )
        
        XCTAssertEqual(
            sut.chartPoints.count,
            31
        )
        
        XCTAssertEqual(
            sut.statistics.totalAmount,
            0
        )
        
        XCTAssertEqual(
            sut.statistics.averageAmount,
            0
        )
        
        XCTAssertEqual(
            sut.statistics.completionRate,
            0
        )
        
        XCTAssertEqual(
            sut.statistics.entriesCount,
            31
        )
        
        XCTAssertEqual(
            sut.statistics.goalReachedCount,
            0
        )
        
        XCTAssertEqual(
            sut.statistics.bestAmount,
            0
        )
    }
    
    // MARK: - Year Analytics
    
    func testMakeAnalytics_forYear_createsTwelveChartPoints() {
        // Arrange
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let entries = [
            makeEntry(
                amount: 1000,
                date: makeDate(year: 2026, month: 1, day: 10)
            ),
            makeEntry(
                amount: 2000,
                date: makeDate(year: 2026, month: 5, day: 10)
            )
        ]
        
        // Act
        let sut = HistoryAnalyticsService.makeAnalytics(
            period: .year,
            entries: entries,
            dailyGoalProvider: { _ in 2000 },
            referenceDate: referenceDate
        )
        
        // Assert
        XCTAssertEqual(
            sut.period,
            .year
        )
        
        XCTAssertEqual(
            sut.chartPoints.count,
            12
        )
        
        XCTAssertEqual(
            sut.statistics.totalAmount,
            3000
        )
        
        XCTAssertEqual(
            sut.statistics.averageAmount,
            1500
        )
        
        XCTAssertEqual(
            sut.statistics.entriesCount,
            12
        )
    }
    
    // MARK: - Drink Breakdown
    
    func testMakeAnalytics_groupsDrinkBreakdownByDrinkTypeAndSortsByAmountDescending() {
        // Arrange
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        let entries = [
            makeEntry(amount: 200, date: referenceDate, drinkType: .water),
            makeEntry(amount: 300, date: referenceDate, drinkType: .water),
            makeEntry(amount: 700, date: referenceDate, drinkType: .coffee),
            makeEntry(amount: 100, date: referenceDate, drinkType: .tea)
        ]
        
        // Act
        let sut = HistoryAnalyticsService.makeAnalytics(
            period: .day,
            entries: entries,
            dailyGoalProvider: { _ in 2000 },
            referenceDate: referenceDate
        )
        
        // Assert
        XCTAssertEqual(
            sut.drinkBreakdown,
            [
                DrinkBreakdownItem(
                    drinkType: .coffee,
                    amount: 700
                ),
                DrinkBreakdownItem(
                    drinkType: .water,
                    amount: 500
                ),
                DrinkBreakdownItem(
                    drinkType: .tea,
                    amount: 100
                )
            ]
        )
    }
    
    // MARK: - Empty State
    
    func testMakeAnalytics_forDayWithEmptyEntries_returnsEmptyStatisticsAndEmptyChart() {
        // Arrange
        let referenceDate = makeDate(
            year: 2026,
            month: 5,
            day: 25
        )
        
        // Act
        let sut = HistoryAnalyticsService.makeAnalytics(
            period: .day,
            entries: [],
            dailyGoalProvider: { _ in 2000 },
            referenceDate: referenceDate
        )
        
        // Assert
        XCTAssertEqual(
            sut.statistics,
            .empty
        )
        
        XCTAssertTrue(
            sut.chartPoints.isEmpty
        )
        
        XCTAssertTrue(
            sut.entries.isEmpty
        )
        
        XCTAssertTrue(
            sut.drinkBreakdown.isEmpty
        )
    }
    
    // MARK: - Helpers
    
    private func makeEntry(
        id: UUID = UUID(),
        amount: Int,
        date: Date,
        drinkType: DrinkType = .water
    ) -> WaterEntry {
        WaterEntry(
            id: id,
            amount: amount,
            date: date,
            drinkType: drinkType
        )
    }
    
    private func makeDate(
        year: Int,
        month: Int,
        day: Int,
        hour: Int = 12,
        minute: Int = 0
    ) -> Date {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        
        return components.date!
    }
}
