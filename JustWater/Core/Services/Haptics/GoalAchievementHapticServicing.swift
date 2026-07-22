//
//  GoalAchievementHapticServicing.swift
//  JustWater
//
//  Created by сонный on 22.07.2026.
//

import CoreHaptics
import Foundation

@MainActor
protocol GoalAchievementHapticServicing {
    func play()
}

@MainActor
final class GoalAchievementHapticService: GoalAchievementHapticServicing {

    // MARK: - Dependencies

    private let fallbackService: HapticServicing

    // MARK: - State

    private let supportsHaptics: Bool
    private var engine: CHHapticEngine?
    private var player: (any CHHapticPatternPlayer)?
    private var pattern: CHHapticPattern?
    private var isEngineStarted = false
    private var shouldRestartAfterReset = false

    // MARK: - Initializer

    init(
        fallbackService: HapticServicing
    ) {
        self.fallbackService = fallbackService
        self.supportsHaptics = CHHapticEngine
            .capabilitiesForHardware()
            .supportsHaptics
    }

    // MARK: - Public Methods

    func play() {
        guard AppSettingsStorage.isHapticsEnabled else { return }
        guard supportsHaptics else {
            fallbackService.success()
            return
        }

        do {
            let engine = try makeEngineIfNeeded()
            try engine.start()
            isEngineStarted = true

            let player = try engine.makePlayer(
                with: makePatternIfNeeded()
            )
            self.player = player
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            fallbackService.success()
        }
    }

    // MARK: - Private Methods

    private func makeEngineIfNeeded() throws -> CHHapticEngine {
        if let engine {
            return engine
        }

        let engine = try CHHapticEngine()
        engine.playsHapticsOnly = true
        engine.isAutoShutdownEnabled = true
        configureHandlers(for: engine)
        self.engine = engine
        return engine
    }

    private func configureHandlers(
        for engine: CHHapticEngine
    ) {
        engine.stoppedHandler = { [weak self, weak engine] reason in
            Task { @MainActor [weak self, weak engine] in
                guard let self,
                      let engine,
                      self.engine === engine
                else {
                    return
                }

                shouldRestartAfterReset = reason == .systemError
                    && isEngineStarted
                isEngineStarted = false
                player = nil
            }
        }

        engine.resetHandler = { [weak self, weak engine] in
            Task { @MainActor [weak self, weak engine] in
                guard let self,
                      let engine,
                      self.engine === engine
                else {
                    return
                }

                let shouldRestart = isEngineStarted
                    || shouldRestartAfterReset
                isEngineStarted = false
                shouldRestartAfterReset = false
                player = nil

                guard shouldRestart,
                      AppSettingsStorage.isHapticsEnabled
                else {
                    return
                }

                do {
                    try engine.start()
                    isEngineStarted = true
                } catch {
                    isEngineStarted = false
                }
            }
        }
    }

    private func makePatternIfNeeded() throws -> CHHapticPattern {
        if let pattern {
            return pattern
        }

        let events: [CHHapticEvent] = [
            makeTransientEvent(
                relativeTime: 0.00,
                intensity: 1.00,
                sharpness: 0.85
            ),

            makeContinuousEvent(
                relativeTime: 0.04,
                duration: 0.32,
                intensity: 1.00,
                sharpness: 0.25
            ),

            makeTransientEvent(
                relativeTime: 0.18,
                intensity: 1.00,
                sharpness: 0.55
            ),

            makeTransientEvent(
                relativeTime: 0.42,
                intensity: 1.00,
                sharpness: 0.35
            ),
            
            makeTransientEvent(
                relativeTime: 0.58,
                intensity: 0.85,
                sharpness: 0.75
            )
        ]

        let pattern = try CHHapticPattern(
            events: events,
            parameters: []
        )

        self.pattern = pattern
        return pattern
    }
    
    private func makeContinuousEvent(
        relativeTime: TimeInterval,
        duration: TimeInterval,
        intensity: Float,
        sharpness: Float
    ) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: intensity
                ),
                CHHapticEventParameter(
                    parameterID: .hapticSharpness,
                    value: sharpness
                )
            ],
            relativeTime: relativeTime,
            duration: duration
        )
    }

    private func makeTransientEvent(
        relativeTime: TimeInterval,
        intensity: Float,
        sharpness: Float
    ) -> CHHapticEvent {
        CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(
                    parameterID: .hapticIntensity,
                    value: intensity
                ),
                CHHapticEventParameter(
                    parameterID: .hapticSharpness,
                    value: sharpness
                )
            ],
            relativeTime: relativeTime
        )
    }
}
