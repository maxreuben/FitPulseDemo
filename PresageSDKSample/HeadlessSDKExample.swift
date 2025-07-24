//
//  HeadlessSDKExample.swift
//  PresageSDKSample
//
//  Created by Reuben Varghese on 7/17/25.
//

import SwiftUI
import SmartSpectraSwiftSDK
import AVFoundation

struct HeadlessSDKExample: View {
    @ObservedObject var sdk = SmartSpectraSwiftSDK.shared
    @ObservedObject var vitalsProcessor = SmartSpectraVitalsProcessor.shared
    @State private var isVitalMonitoringEnabled: Bool = false
    @State var smartSpectraMode: SmartSpectraMode = .continuous
    @State private var minPulseRate: Int = 0
    @State private var maxPulseRate: Int = 0
    @State private var averagePulseRate: Int = 0
    @State private var collectedRates: [Double] = []
    @State private var permissionDenied: Bool = false
    @State private var showPermissionAlert: Bool = false
    
    private var statusText: String {
        permissionDenied ? "Permissions denied" : vitalsProcessor.statusHint
    }
    
    @Environment(\.colorScheme) private var environmentColorScheme
    @State private var overrideColorScheme: ColorScheme? = nil
    
    init() {
        // (Required) Authentication. Only need to use one of the two options: API Key or Oauth below
        // Authentication with Oauth currently only supported for apps in testflight/appstore
        // Option 1: (authentication with api key) set apiKey. API key from https://physiology.presagetech.com. Leave default or remove if you want to use oauth. Oauth overrides api key
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String else {
            fatalError("Missing API_KEY")
        }
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
                                Text("Status: \(statusText)")
                                    .foregroundColor(permissionDenied ? Color.red : Color.primary)
                        }
                        
                        GridRow {
                            HStack {
                                Text("Vitals Monitoring")
                                Circle()
                                    .fill(isVitalMonitoringEnabled ? Color.green : Color.red)
                                    .frame(width: 10, height: 10)
                                Spacer()
                                Button(isVitalMonitoringEnabled ? "Stop": "Start") {
                                    if permissionDenied {
                                        showPermissionAlert = true
                                    } else {
                                        isVitalMonitoringEnabled.toggle()
                                        if isVitalMonitoringEnabled {
                                            startVitalsMonitoring()
                                        } else {
                                            stopVitalsMonitoring()
                                        }
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
        .onAppear {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    DispatchQueue.main.async {
                        permissionDenied = !granted
                    }
                }
            case .denied, .restricted:
                permissionDenied = true
            case .authorized:
                permissionDenied = false
            @unknown default:
                permissionDenied = true
            }
        }
        .onReceive(sdk.$metricsBuffer) { metricsBuffer in
            guard isVitalMonitoringEnabled else { return }
            guard let buffer = metricsBuffer, buffer.isInitialized else { return }
            let newRates = buffer.pulse.rate.map { Double($0.value) }
            guard !newRates.isEmpty else { return }

            collectedRates.append(contentsOf: newRates)

            let minValue = collectedRates.min()!
            let maxValue = collectedRates.max()!
            let sum = collectedRates.reduce(0, +)
            let avgValue = sum / Double(collectedRates.count)

            minPulseRate = Int(minValue.rounded())
            maxPulseRate = Int(maxValue.rounded())
            averagePulseRate = Int(avgValue.rounded())
        }
    .id(overrideColorScheme ?? environmentColorScheme)
    .preferredColorScheme(overrideColorScheme)
    .alert("Camera Permission Required", isPresented: $showPermissionAlert) {
        Button("Open Settings") {
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        Button("Cancel", role: .cancel) { }
    } message: {
        Text("Please allow camera access in Settings to use vitals monitoring.")
    }
    }

    func startVitalsMonitoring() {
        collectedRates = []
        minPulseRate = 0
        maxPulseRate = 0
        averagePulseRate = 0
        vitalsProcessor.startProcessing()
        vitalsProcessor.startRecording()
    }

    func stopVitalsMonitoring() {
        vitalsProcessor.stopProcessing()
        vitalsProcessor.stopRecording()

        if !collectedRates.isEmpty {
            let minValue = collectedRates.min()!
            let maxValue = collectedRates.max()!
            let sum = collectedRates.reduce(0, +)
            let avgValue = sum / Double(collectedRates.count)
            minPulseRate = Int(minValue.rounded())
            maxPulseRate = Int(maxValue.rounded())
            averagePulseRate = Int(avgValue.rounded())
        }
    }
}
