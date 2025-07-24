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
    @State private var hasSavedStats: Bool = UserDefaults.standard.bool(forKey: "hasStats")
    @State private var isVitalMonitoringEnabled: Bool = false
    @State var smartSpectraMode: SmartSpectraMode = .continuous
    @State private var minPulseRate: Int = {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "hasStats") ? defaults.integer(forKey: "minPulseRate") : 0
    }()
    @State private var maxPulseRate: Int = {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "hasStats") ? defaults.integer(forKey: "maxPulseRate") : 0
    }()
    @State private var averagePulseRate: Int = {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "hasStats") ? defaults.integer(forKey: "averagePulseRate") : 0
    }()
    
    @Environment(\.colorScheme) private var environmentColorScheme
    @State private var overrideColorScheme: ColorScheme? = nil
    
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
        ZStack {
            VStack {
                GroupBox(label:
                    HStack {
                        Text("Vitals")
                        Spacer()
                        Picker("", selection: $overrideColorScheme) {
                            Text("System").tag(nil as ColorScheme?)
                            Text("Light").tag(ColorScheme.light as ColorScheme?)
                            Text("Dark").tag(ColorScheme.dark as ColorScheme?)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 200)
                    }
                ) {
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
                    .padding(.horizontal, 12)
                    HStack(alignment: .bottom) {
                        VStack {
                            Text("Min Pulse Rate: \(minPulseRate) bpm")
                                .font(.subheadline)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        
                        VStack {
                            Text("Max Pulse Rate: \(maxPulseRate) bpm")
                                .font(.subheadline)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        
                        VStack {
                            Text("Avg Pulse Rate: \(averagePulseRate) bpm")
                                .font(.subheadline)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
        .onReceive(sdk.$metricsBuffer) { metricsBuffer in
            guard isVitalMonitoringEnabled else { return }
            guard let buffer = metricsBuffer, buffer.isInitialized else { return }
            let rates = buffer.pulse.rate.map { Double($0.value) }
            guard !rates.isEmpty else { return }
            let minValue = rates.min() ?? 0
            let maxValue = rates.max() ?? 0
            let sum = rates.reduce(0, +)
            let avgValue = sum / Double(rates.count)
            minPulseRate = Int(minValue.rounded())
            maxPulseRate = Int(maxValue.rounded())
            averagePulseRate = Int(avgValue.rounded())
        }
    .id(overrideColorScheme ?? environmentColorScheme)
    .preferredColorScheme(overrideColorScheme)
    }

    func startVitalsMonitoring() {
        // Reset stored stats when starting monitoring
        minPulseRate = 0
        maxPulseRate = 0
        averagePulseRate = 0
        vitalsProcessor.startProcessing()
        vitalsProcessor.startRecording()
    }

    func stopVitalsMonitoring() {
        vitalsProcessor.stopProcessing()
        vitalsProcessor.stopRecording()
        let defaults = UserDefaults.standard
        defaults.set(minPulseRate, forKey: "minPulseRate")
        defaults.set(maxPulseRate, forKey: "maxPulseRate")
        defaults.set(averagePulseRate, forKey: "averagePulseRate")
        defaults.set(true, forKey: "hasStats")
    }
}
