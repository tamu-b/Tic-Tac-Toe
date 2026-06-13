//
//  GameView.swift
//  Tic-Tac-Toe
//
//  Created on 2026/06/13.
//

import SwiftUI

struct GameView: View {
    @State private var gameState: GameState
    @State private var isAIThinking = false
    @State private var navigateToResult = false
    
    let mode: GameMode
    
    init(mode: GameMode) {
        self.mode = mode
        _gameState = State(initialValue: GameState(mode: mode))
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // 現在のプレイヤー表示
            if gameState.result == nil {
                Text("\(gameState.currentPlayer.rawValue)の番です")
                    .font(.title)
                    .fontWeight(.bold)
            } else {
                Text("ゲーム終了")
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            // ゲームボード
            GameBoardView(
                board: gameState.board,
                result: gameState.result,
                onCellTapped: handleCellTap
            )
            .disabled(isAIThinking || gameState.result != nil)
            
            // 待ったボタン
            Button(action: {
                handleUndo()
            }) {
                Text("待った")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canUndo ? Color.orange : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!canUndo || isAIThinking)
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 40)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = gameState.result {
                ResultView(
                    result: result,
                    board: gameState.board,
                    mode: mode
                )
            }
        }
        .onChange(of: gameState.result) { _, newResult in
            if newResult != nil {
                // 結果画面への遷移を少し遅延
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    navigateToResult = true
                }
            }
        }
        .onAppear {
            checkAITurn()
        }
    }
    
    private var canUndo: Bool {
        gameState.history.count > 1 && gameState.result == nil
    }
    
    private func handleCellTap(index: Int) {
        guard !isAIThinking else { return }
        
        if gameState.makeMove(at: index) {
            checkAITurn()
        }
    }
    
    private func handleUndo() {
        guard canUndo else { return }
        
        // 1人プレイの場合は2手戻す（プレイヤーとAIの手）
        if case .onePlayer = mode {
            _ = gameState.undo()
            _ = gameState.undo()
        } else {
            _ = gameState.undo()
        }
    }
    
    private func checkAITurn() {
        guard case .onePlayer(let playerStarts, let randomOrder) = mode else {
            return
        }
        
        guard gameState.result == nil else {
            return
        }
        
        // AIのプレイヤーを判定
        let aiPlayer: Player
        if randomOrder {
            // ランダムの場合、プレイヤーは○、AIは×
            aiPlayer = .cross
        } else {
            aiPlayer = playerStarts ? .cross : .circle
        }
        
        // 現在のターンがAIかチェック
        if gameState.currentPlayer == aiPlayer {
            isAIThinking = true
            
            // AIの思考時間をシミュレート
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let move = gameState.getAIMove() {
                    _ = gameState.makeMove(at: move)
                }
                isAIThinking = false
            }
        }
    }
}

struct GameBoardView: View {
    let board: [Cell]
    let result: GameResult?
    let onCellTapped: (Int) -> Void
    
    private let gridSize: CGFloat = 3
    private let spacing: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            let cellSize = (geometry.size.width - spacing * (gridSize + 1)) / gridSize
            
            VStack(spacing: spacing) {
                ForEach(0..<Int(gridSize), id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<Int(gridSize), id: \.self) { col in
                            let index = row * Int(gridSize) + col
                            CellView(
                                cell: board[index],
                                isWinningCell: isWinningCell(index),
                                size: cellSize
                            )
                            .onTapGesture {
                                onCellTapped(index)
                            }
                        }
                    }
                }
            }
            .padding(spacing)
            .background(Color.gray.opacity(0.3))
            .cornerRadius(12)
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.horizontal, 30)
    }
    
    private func isWinningCell(_ index: Int) -> Bool {
        if case .win(_, let winningLine) = result {
            return winningLine.contains(index)
        }
        return false
    }
}

struct CellView: View {
    let cell: Cell
    let isWinningCell: Bool
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(isWinningCell ? Color.yellow.opacity(0.5) : Color.white)
                .frame(width: size, height: size)
                .cornerRadius(8)
            
            if let player = cell.player {
                Text(player.rawValue)
                    .font(.system(size: size * 0.6, weight: .bold))
                    .foregroundColor(player == .circle ? .red : .blue)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isWinningCell)
    }
}

#Preview {
    NavigationStack {
        GameView(mode: .twoPlayers)
    }
}
