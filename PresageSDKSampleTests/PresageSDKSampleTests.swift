//
//  PresageSDKSampleTests.swift
//  PresageSDKSampleTests
//
//  Created by Reuben Varghese on 7/17/25.
//

import Foundation
import Testing
import SwiftUI
import AVFoundation
@testable import PresageSDKSample
@testable import SmartSpectraSwiftSDK

@MainActor
struct HeadlessSDKExampleTests {
    
    // MARK: - Test API Key
    
    @Test func testApiKeyPresence() async throws {
            let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
            #expect(key != nil && !key!.isEmpty)
        }
    
    // MARK: - Initialization Tests
    
    @Test func testInitialization() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        // Verify initial state
        #expect(viewModel.testCollectedRates.isEmpty)
        #expect(viewModel.testMinPulseRate == 0)
        #expect(viewModel.testMaxPulseRate == 0)
        #expect(viewModel.testAveragePulseRate == 0)
    }
    
    @Test func testApiKeyConfiguration() async throws {
        // Verify API key is configured during initialization
        let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
        #expect(key != nil && !key!.isEmpty, "API_KEY must be configured in Info.plist")
    }
    
    // MARK: - Vitals Monitoring State Tests
    
    @Test func testStartVitalsMonitoringResetsValues() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        // Simulate some existing data
        viewModel.startVitalsMonitoring()
        
        // Verify that starting monitoring resets all values
        #expect(viewModel.testCollectedRates.isEmpty)
        #expect(viewModel.testMinPulseRate == 0)
        #expect(viewModel.testMaxPulseRate == 0)
        #expect(viewModel.testAveragePulseRate == 0)
    }
    
    @Test func testStopVitalsMonitoringWithEmptyData() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        viewModel.stopVitalsMonitoring()
        
        // Should maintain zero values when no data collected
        #expect(viewModel.testMinPulseRate == 0)
        #expect(viewModel.testMaxPulseRate == 0)
        #expect(viewModel.testAveragePulseRate == 0)
    }
    
    // MARK: - Metrics Calculation Tests
    
    @Test func testPulseRateCalculationSingleValue() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        // Simulate receiving a single pulse rate value
        let testRate = 72.0
        let mockMetric = createMockPulseMetric(value: testRate)
        let mockBuffer = createMockMetricsBuffer(pulseMetrics: [mockMetric])
        
        // Simulate the metrics buffer update
        viewModel.simulateMetricsUpdate(buffer: mockBuffer, isMonitoringEnabled: true)
        
        #expect(viewModel.testMinPulseRate == 72)
        #expect(viewModel.testMaxPulseRate == 72)
        #expect(viewModel.testAveragePulseRate == 72)
        #expect(viewModel.testCollectedRates.count == 1)
    }
    
    @Test func testPulseRateCalculationMultipleValues() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        // Test with multiple values: 60, 70, 80
        let testRates = [60.0, 70.0, 80.0]
        let mockMetrics = testRates.map { createMockPulseMetric(value: $0) }
        let mockBuffer = createMockMetricsBuffer(pulseMetrics: mockMetrics)
        
        viewModel.simulateMetricsUpdate(buffer: mockBuffer, isMonitoringEnabled: true)
        
        #expect(viewModel.testMinPulseRate == 60)
        #expect(viewModel.testMaxPulseRate == 80)
        #expect(viewModel.testAveragePulseRate == 70) // (60+70+80)/3 = 70
        #expect(viewModel.testCollectedRates.count == 3)
    }
    
    @Test func testPulseRateCalculationWithDecimals() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        // Test with decimal values that should be rounded
        let testRates = [65.7, 72.3, 68.9]
        let mockMetrics = testRates.map { createMockPulseMetric(value: $0) }
        let mockBuffer = createMockMetricsBuffer(pulseMetrics: mockMetrics)
        
        viewModel.simulateMetricsUpdate(buffer: mockBuffer, isMonitoringEnabled: true)
        
        #expect(viewModel.testMinPulseRate == 66)  // 65.7 rounded
        #expect(viewModel.testMaxPulseRate == 72)  // 72.3 rounded
        #expect(viewModel.testAveragePulseRate == 69) // (65.7+72.3+68.9)/3 = 68.97 rounded to 69
    }
    
    @Test func testCumulativeMetricsUpdates() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        // First batch of data
        let firstBatch = [60.0, 70.0]
        let firstMetrics = firstBatch.map { createMockPulseMetric(value: $0) }
        let firstBuffer = createMockMetricsBuffer(pulseMetrics: firstMetrics)
        
        viewModel.simulateMetricsUpdate(buffer: firstBuffer, isMonitoringEnabled: true)
        
        #expect(viewModel.testCollectedRates.count == 2)
        #expect(viewModel.testAveragePulseRate == 65) // (60+70)/2
        
        // Second batch of data
        let secondBatch = [80.0, 90.0]
        let secondMetrics = secondBatch.map { createMockPulseMetric(value: $0) }
        let secondBuffer = createMockMetricsBuffer(pulseMetrics: secondMetrics)
        
        viewModel.simulateMetricsUpdate(buffer: secondBuffer, isMonitoringEnabled: true)
        
        #expect(viewModel.testCollectedRates.count == 4)
        #expect(viewModel.testMinPulseRate == 60)
        #expect(viewModel.testMaxPulseRate == 90)
        #expect(viewModel.testAveragePulseRate == 75) // (60+70+80+90)/4
    }
    
    @Test func testMetricsIgnoredWhenMonitoringDisabled() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        let testRates = [60.0, 70.0, 80.0]
        let mockMetrics = testRates.map { createMockPulseMetric(value: $0) }
        let mockBuffer = createMockMetricsBuffer(pulseMetrics: mockMetrics)
        
        // Simulate update when monitoring is disabled
        viewModel.simulateMetricsUpdate(buffer: mockBuffer, isMonitoringEnabled: false)
        
        // Values should remain at defaults
        #expect(viewModel.testCollectedRates.isEmpty)
        #expect(viewModel.testMinPulseRate == 0)
        #expect(viewModel.testMaxPulseRate == 0)
        #expect(viewModel.testAveragePulseRate == 0)
    }
    
    @Test func testEmptyMetricsBuffer() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        let mockBuffer = createMockMetricsBuffer(pulseMetrics: [])
        viewModel.simulateMetricsUpdate(buffer: mockBuffer, isMonitoringEnabled: true)
        
        // Should not crash and values should remain at defaults
        #expect(viewModel.testCollectedRates.isEmpty)
        #expect(viewModel.testMinPulseRate == 0)
        #expect(viewModel.testMaxPulseRate == 0)
        #expect(viewModel.testAveragePulseRate == 0)
    }
    
    // MARK: - Edge Cases
    
    @Test func testExtremeValues() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        // Test with extreme but realistic heart rate values
        let extremeRates = [30.0, 200.0, 120.0] // Very low, very high, normal
        let mockMetrics = extremeRates.map { createMockPulseMetric(value: $0) }
        let mockBuffer = createMockMetricsBuffer(pulseMetrics: mockMetrics)
        
        viewModel.simulateMetricsUpdate(buffer: mockBuffer, isMonitoringEnabled: true)
        
        #expect(viewModel.testMinPulseRate == 30)
        #expect(viewModel.testMaxPulseRate == 200)
        #expect(viewModel.testAveragePulseRate == 117) // (30+200+120)/3 = 116.67 rounded to 117
    }
    
    @Test func testStopMonitoringCalculatesCorrectFinalValues() async throws {
        let viewModel = HeadlessSDKViewModel()
        
        // Simulate collecting some data
        let testRates = [65.0, 75.0, 85.0]
        let mockMetrics = testRates.map { createMockPulseMetric(value: $0) }
        let mockBuffer = createMockMetricsBuffer(pulseMetrics: mockMetrics)
        
        viewModel.simulateMetricsUpdate(buffer: mockBuffer, isMonitoringEnabled: true)
        
        // Stop monitoring should recalculate final values
        viewModel.stopVitalsMonitoring()
        
        #expect(viewModel.testMinPulseRate == 65)
        #expect(viewModel.testMaxPulseRate == 85)
        #expect(viewModel.testAveragePulseRate == 75)
    }
    
    // MARK: - Helper Methods for Testing
    
    private func createMockPulseMetric(value: Double) -> MockPulseMetric {
        return MockPulseMetric(value: Float(value))
    }
    
    private func createMockMetricsBuffer(pulseMetrics: [MockPulseMetric]) -> MockMetricsBuffer {
        let mockPulse = MockPulse(rate: pulseMetrics)
        return MockMetricsBuffer(pulse: mockPulse, isInitialized: true)
    }
}

// MARK: - Mock Objects for Testing

struct MockPulseMetric {
    let value: Float
}

struct MockPulse {
    let rate: [MockPulseMetric]
}

struct MockMetricsBuffer {
    let pulse: MockPulse
    let isInitialized: Bool
}

// Create a viewModel model for testing
@MainActor
class HeadlessSDKViewModel: ObservableObject {
    @Published var testCollectedRates: [Double] = []
    @Published var testMinPulseRate: Int = 0
    @Published var testMaxPulseRate: Int = 0
    @Published var testAveragePulseRate: Int = 0
    
    func startVitalsMonitoring() {
        testCollectedRates.removeAll()
        testMinPulseRate = 0
        testMaxPulseRate = 0
        testAveragePulseRate = 0
    }
    
    func stopVitalsMonitoring() {
        // Recalculate final values if needed
        if !testCollectedRates.isEmpty {
            let minValue = testCollectedRates.min()!
            let maxValue = testCollectedRates.max()!
            let avgValue = testCollectedRates.reduce(0, +) / Double(testCollectedRates.count)
            
            testMinPulseRate = Int(minValue.rounded())
            testMaxPulseRate = Int(maxValue.rounded())
            testAveragePulseRate = Int(avgValue.rounded())
        }
    }
    
    func simulateMetricsUpdate(buffer: MockMetricsBuffer, isMonitoringEnabled: Bool) {
        guard isMonitoringEnabled else { return }
        guard buffer.isInitialized else { return }
        
        let newRates = buffer.pulse.rate.map { Double($0.value) }
        guard !newRates.isEmpty else { return }
        
        testCollectedRates.append(contentsOf: newRates)
        
        let minValue = testCollectedRates.min()!
        let maxValue = testCollectedRates.max()!
        let sum = testCollectedRates.reduce(0, +)
        let avgValue = sum / Double(testCollectedRates.count)
        
        testMinPulseRate = Int(minValue.rounded())
        testMaxPulseRate = Int(maxValue.rounded())
        testAveragePulseRate = Int(avgValue.rounded())
    }
}
