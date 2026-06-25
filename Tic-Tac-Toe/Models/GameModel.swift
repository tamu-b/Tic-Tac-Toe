//
//  GameModel.swift
//  Tic-Tac-Toe
//
//  Created on 2026/06/13.
//

import Foundation

enum Player: String {
    case circle = "○"
    case cross = "×"
    
    var opposite: Player {
        self == .circle ? .cross : .circle
    }
}

enum Cell: Equatable {
    case empty
    case occupied(Player)
    
    var player: Player? {
        if case .occupied(let player) = self {
            return player
        }
        return nil
    }
}

enum GameMode {
    case onePlayer(playerStarts: Bool, randomOrder: Bool)
    case twoPlayers
}

enum GameResult: Equatable {
    case win(Player, winningLine: [Int])
    case draw
}

struct GameState {
    var board: [Cell] = Array(repeating: .empty, count: 9)
    var currentPlayer: Player = .circle
    var history: [[Cell]] = []
    var result: GameResult?
    var mode: GameMode
    
    init(mode: GameMode) {
        self.mode = mode
        
        // ランダム順序の場合、先手を決定
        if case .onePlayer(_, let randomOrder) = mode, randomOrder {
            currentPlayer = Bool.random() ? .circle : .cross
        }
        
        history.append(board)
    }
    
    mutating func makeMove(at index: Int) -> Bool {
        guard result == nil,
              board[index] == .empty else {
            return false
        }
        
        board[index] = .occupied(currentPlayer)
        history.append(board)
        
        // 勝敗判定
        if let winningLine = checkWin(for: currentPlayer) {
            result = .win(currentPlayer, winningLine: winningLine)
        } else if board.allSatisfy({ $0 != .empty }) {
            result = .draw
        } else {
            currentPlayer = currentPlayer.opposite
        }
        
        return true
    }
    
    mutating func undo() -> Bool {
        guard history.count > 1 else {
            return false
        }
        
        history.removeLast()
        board = history.last!
        result = nil
        
        // プレイヤーを戻す
        let occupiedCount = board.filter { $0 != .empty }.count
        
        // 初期プレイヤーを考慮
        let initialPlayer: Player
        if case .onePlayer(let playerStarts, let randomOrder) = mode {
            if randomOrder {
                // ゲーム開始時に決定された先手を使用
                // historyの最初の状態から判断
                initialPlayer = .circle // デフォルト、実際は保存が必要
            } else {
                initialPlayer = playerStarts ? .circle : .cross
            }
        } else {
            initialPlayer = .circle
        }
        
        currentPlayer = occupiedCount % 2 == 0 ? initialPlayer : initialPlayer.opposite
        
        return true
    }
    
    private func checkWin(for player: Player) -> [Int]? {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8], // 横
            [0, 3, 6], [1, 4, 7], [2, 5, 8], // 縦
            [0, 4, 8], [2, 4, 6]              // 斜め
        ]
        
        for pattern in winPatterns {
            if pattern.allSatisfy({ board[$0].player == player }) {
                return pattern
            }
        }
        
        return nil
    }
    
    func getAIMove() -> Int? {
        let emptyIndices = board.enumerated()
            .filter { $0.element == .empty }
            .map { $0.offset }

        // AIが勝てる場合は勝利
        if let winIndex = findWinningMove(for: currentPlayer, in: emptyIndices) {
            return winIndex
        }

        // 相手（人間プレイヤー）がリーチの場合はブロック
        let humanPlayer = currentPlayer.opposite
        if let blockIndex = findWinningMove(for: humanPlayer, in: emptyIndices) {
            return blockIndex
        }

        return emptyIndices.randomElement()
    }

    private func findWinningMove(for player: Player, in emptyIndices: [Int]) -> Int? {
        let winPatterns: [[Int]] = [
            [0, 1, 2], [3, 4, 5], [6, 7, 8],
            [0, 3, 6], [1, 4, 7], [2, 5, 8],
            [0, 4, 8], [2, 4, 6]
        ]

        for pattern in winPatterns {
            let playerCells = pattern.filter { board[$0].player == player }
            let emptyCells = pattern.filter { board[$0] == .empty }
            if playerCells.count == 2, emptyCells.count == 1, let move = emptyCells.first {
                return move
            }
        }
        return nil
    }
}
