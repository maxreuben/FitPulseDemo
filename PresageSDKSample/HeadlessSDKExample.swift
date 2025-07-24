//
//  HeadlessSDKExample.swift
//  PresageSDKSample
//
//  Created by Reuben Varghese on 7/17/25.
//

import SwiftUI
import SmartSpectraSwiftSDK

struct HeadlessSDKExample: View {
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    @ObservedObject var vitalsProcessor = SmartSpectraVitalsProcessor.shared
    @State private var isVitalMonitoringEnabled: Bool = false
    @State var smartSpectraMode: SmartSpectraMode = .continuous
    @State private var minPulseRate: Int = 0
    @State private var maxPulseRate: Int = 0
    @State private var averagePulseRate: Int = 0
    
    init() {
        // (Required) Authentication. Only need to use one of the two options: API Key or Oauth below
        // Authentication with Oauth currently only supported for apps in testflight/appstore
        // Option 1: (authentication with api key) set apiKey. API key from https://physiology.presagetech.com. Leave default or remove if you want to use oauth. Oauth overrides api key
        let apiKey = "PMy4i6XfMzafy6EbD8Wfm9ols9ZdF47j9RvOi8g1"
        sdk.setApiKey(apiKey)
        
        // Option 2: (Oauth) If you want to use Oauth, copy the Oauth config from PresageTech's developer portal (<https://physiology.presagetech.com/>) to your app's root.
        // No additional code needed for Oauth
    }
    
    var body: some View {
        VStack {
            GroupBox(label: Text("Vitals")) {
                ContinuousVitalsPlotView()
                Grid {
                    GridRow {
                        Text("Status: \(vitalsProcessor.statusHint)")
                    }
                    
                    GridRow {
                        HStack {
                            Text("Vitals Monitoring")
                            Spacer()
                            Button(isVitalMonitoringEnabled ? "Stop": "Start") {
                                isVitalMonitoringEnabled.toggle()
                                if(isVitalMonitoringEnabled) {
                                    startVitalsMonitoring()
                                } else {
                                    stopVitalsMonitoring()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
            Text("Min Pulse Rate: \(minPulseRate) bpm")
                .padding(.horizontal, 10)
            Text("Max Pulse Rate: \(maxPulseRate) bpm")
                .padding(.horizontal, 10)
            Text("Avg Pulse Rate: \(averagePulseRate) bpm")
                .padding(.horizontal, 10)
        }
        .onReceive(sdk.$metricsBuffer) { metricsBuffer in
            guard let buffer = metricsBuffer, buffer.isInitialized else { return }
            let rates = buffer.pulse.rate.map { Double($0.value) }
            guard !rates.isEmpty else { return }
            let minValue = rates.min()!
            let maxValue = rates.max()!
            let sum = rates.reduce(0, +)
            let avgValue = sum / Double(rates.count)
            minPulseRate = Int(minValue.rounded())
            maxPulseRate = Int(maxValue.rounded())
            averagePulseRate = Int(avgValue.rounded())
        }
    }

    func startVitalsMonitoring() {
        vitalsProcessor.startProcessing()
        vitalsProcessor.startRecording()
    }

    func stopVitalsMonitoring() {
        vitalsProcessor.stopProcessing()
        vitalsProcessor.stopRecording()

    }
}
