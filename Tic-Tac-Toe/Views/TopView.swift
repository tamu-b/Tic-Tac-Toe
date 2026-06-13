//
//  TopView.swift
//  Tic-Tac-Toe
//
//  Created on 2026/06/13.
//

import SwiftUI

enum GameModeSelection {
    case onePlayer
    case twoPlayers
}

enum PlayerOrder {
    case playerFirst
    case aiFirst
    case random
}

struct TopView: View {
    @State private var selectedMode: GameModeSelection?
    @State private var selectedOrder: PlayerOrder = .playerFirst
    @State private var navigateToGame = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // タイトル
                Text("3目並べ")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)
                
                // モード選択
                VStack(spacing: 20) {
                    Button(action: {
                        selectedMode = .onePlayer
                    }) {
                        Text("1人で遊ぶ")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedMode == .onePlayer ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedMode == .onePlayer ? .white : .primary)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        selectedMode = .twoPlayers
                    }) {
                        Text("友達と遊ぶ")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedMode == .twoPlayers ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedMode == .twoPlayers ? .white : .primary)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 40)
                
                // 1人プレイの場合の手番選択
                if selectedMode == .onePlayer {
                    VStack(spacing: 15) {
                        Text("手番を選択")
                            .font(.headline)
                        
                        HStack(spacing: 15) {
                            orderButton(title: "先手", order: .playerFirst)
                            orderButton(title: "後手", order: .aiFirst)
                            orderButton(title: "ランダム", order: .random)
                        }
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity)
                }
                
                // 開始ボタン
                if selectedMode != nil {
                    Button(action: {
                        navigateToGame = true
                    }) {
                        Text("ゲーム開始")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity)
                }
                
                Spacer()
            }
            .padding(.top, 60)
            .animation(.easeInOut, value: selectedMode)
            .navigationDestination(isPresented: $navigateToGame) {
                GameView(mode: createGameMode())
            }
        }
    }
    
    private func orderButton(title: String, order: PlayerOrder) -> some View {
        Button(action: {
            selectedOrder = order
        }) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(selectedOrder == order ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(selectedOrder == order ? .white : .primary)
                .cornerRadius(8)
        }
    }
    
    private func createGameMode() -> GameMode {
        switch selectedMode {
        case .onePlayer:
            let playerStarts = selectedOrder == .playerFirst
            let randomOrder = selectedOrder == .random
            return .onePlayer(playerStarts: playerStarts, randomOrder: randomOrder)
        case .twoPlayers:
            return .twoPlayers
        case .none:
            return .twoPlayers
        }
    }
}

#Preview {
    TopView()
}
