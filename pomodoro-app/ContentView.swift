//
//  ContentView.swift
//  pomodoro-app
//
//  Created by şeyma nur fansa on 15.10.2025.
//
import SwiftUI
import AVFoundation
import Combine
// MARK: - Timer Model
class PomodoroManager: ObservableObject {
    @Published var timeRemaining = 25 * 60
    @Published var isRunning = false
    @Published var isBreak = false
    @Published var completedPomodoros = 0
    @Published var showReward = false

    var timer: Timer?

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stop()
                self.playSound()
                self.nextPhase()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    func reset() {
        stop()
        timeRemaining = isBreak ? 5 * 60 : 25 * 60
    }

    func nextPhase() {
        if !isBreak {
            isBreak = true
            timeRemaining = 5 * 60
            start()
        } else {
            isBreak = false
            completedPomodoros += 1
            showReward = true
            timeRemaining = 25 * 60
        }
    }

    func playSound() {
        AudioServicesPlaySystemSound(1005)
    }
}

// MARK: - Main View
struct ContentView: View {
    @StateObject var pomodoro = PomodoroManager()
    @Environment(\.verticalSizeClass) var verticalSize

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: - Background (soft pastel gradient)
                LinearGradient(
                    gradient: Gradient(colors: pomodoro.isBreak ?
                        [Color("MintPastel"), Color("BeigePastel")] :
                        [Color("LavenderPastel"), Color("PeachPastel")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.2), value: pomodoro.isBreak)

                VStack(spacing: 30) {
                    Text(pomodoro.isBreak ? "Mola Zamanı" : "Odaklanma Zamanı")
                        .font(.system(size: 34, weight: .medium, design: .serif))
                        .italic()
                        .foregroundColor(Color("TextPrimary"))
                        .padding(.top, 50)

                    // MARK: - Circular Timer
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.25), lineWidth: 14)
                            .frame(width: geometry.size.width * 0.6)

                        Circle()
                            .trim(from: 0, to: CGFloat(Double(pomodoro.timeRemaining) / Double(pomodoro.isBreak ? 5*60 : 25*60)))
                            .stroke(
                                AngularGradient(
                                    gradient: Gradient(colors: [Color("Accent1"), Color("Accent2")]),
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 14, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: geometry.size.width * 0.6)
                            .animation(.easeInOut(duration: 0.5), value: pomodoro.timeRemaining)

                        Text(formatTime(pomodoro.timeRemaining))
                            .font(.system(size: 58, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color("TextPrimary"))
                    }
                    .padding(.vertical, 20)

                    // MARK: - Buttons
                    HStack(spacing: 20) {
                        TimerButton(label: "Başlat", systemIcon: "play.fill", action: pomodoro.start)
                        TimerButton(label: "Duraklat", systemIcon: "pause.fill", action: pomodoro.stop)
                        TimerButton(label: "Sıfırla", systemIcon: "arrow.clockwise", action: pomodoro.reset)
                    }

                    // MARK: - Forest & Stats
                    ForestView(completed: pomodoro.completedPomodoros)
                        .padding(.top, 40)

                    Text("Tamamlanan Pomodoro: \(pomodoro.completedPomodoros)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color("TextSecondary"))

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)

                // MARK: - Reward Overlay
                if pomodoro.showReward {
                    RewardView {
                        withAnimation {
                            pomodoro.showReward = false
                        }
                    }
                }
            }
        }
    }

    func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

// MARK: - Timer Button Component
struct TimerButton: View {
    var label: String
    var systemIcon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemIcon)
                Text(label)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.25))
            .foregroundColor(.white)
            .cornerRadius(14)
            .shadow(radius: 2)
        }
    }
}

// MARK: - Forest View
struct ForestView: View {
    var completed: Int

    var body: some View {
        ZStack {
            HStack(spacing: 8) {
                ForEach(0..<completed, id: \.self) { _ in
                    TreeView()
                        .transition(.scale)
                }
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: completed)
    }
}

// MARK: - Tree View (more realistic pastel trees)
struct TreeView: View {
    var body: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color("TreeTrunk"))
                .frame(width: 6, height: 25)
            Circle()
                .fill(LinearGradient(colors: [Color("Leaf1"), Color("Leaf2")], startPoint: .top, endPoint: .bottom))
                .frame(width: 36, height: 36)
                .shadow(color: .green.opacity(0.15), radius: 3, x: 0, y: 2)
        }
    }
}

// MARK: - Reward View
struct RewardView: View {
    var onDismiss: () -> Void
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0.0

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Harika!")
                    .font(.system(size: 30, weight: .semibold, design: .serif))
                    .foregroundColor(.white)
                    .italic()

                Text("Bir fidan diktin 🌿")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))

                Image(systemName: "leaf.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color("Leaf1"))
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.5)) {
                            scale = 1
                            opacity = 1
                        }
                    }

                Button("Devam Et") {
                    onDismiss()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
                .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Custom Pastel Colors
extension Color {
    static let pastelPalette: [Color] = [
        Color("LavenderPastel"), Color("PeachPastel"),
        Color("MintPastel"), Color("BeigePastel")
    ]
}

#Preview {
    ContentView()
}
