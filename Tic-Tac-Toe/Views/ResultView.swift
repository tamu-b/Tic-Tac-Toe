//
//  ResultView.swift
//  Tic-Tac-Toe
//
//  Created on 2026/06/13.
//

import SwiftUI

struct ResultView: View {
    let result: GameResult
    let board: [Cell]
    let mode: GameMode
    let onGoToTop: () -> Void

    @State private var navigateToGame = false
    
    var body: some View {
        VStack(spacing: 40) {
            // 結果表示
            Text(resultText)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(resultColor)
            
            // 決着時の盤面
            GameBoardView(
                board: board,
                result: result,
                onCellTapped: { _ in }
            )
            .disabled(true)
            
            // ボタン
            VStack(spacing: 20) {
                Button(action: {
                    navigateToGame = true
                }) {
                    Text("もう一度")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    onGoToTop()
                }) {
                    Text("トップに戻る")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 60)
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navigateToGame) {
            GameView(mode: mode, onGoToTop: onGoToTop)
        }
    }
    
    private var resultText: String {
        switch result {
        case .win(let player, _):
            return "\(player.rawValue)の勝ち！"
        case .draw:
            return "引き分け"
        }
    }
    
    private var resultColor: Color {
        switch result {
        case .win(let player, _):
            return player == .circle ? .red : .blue
        case .draw:
            return .gray
        }
    }
}

#Preview {
    NavigationStack {
        ResultView(
            result: .win(.circle, winningLine: [0, 1, 2]),
            board: [
                .occupied(.circle), .occupied(.circle), .occupied(.circle),
                .occupied(.cross), .occupied(.cross), .empty,
                .empty, .empty, .occupied(.cross)
            ],
            mode: .twoPlayers,
            onGoToTop: {}
        )
    }
}
