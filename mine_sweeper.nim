import panel
import std/random
import std/strformat
import system
import os

type
    GameStatus* = enum 
        Uninitialized, Playing, Win, Lose 

type
    GameBoard* = ref object of RootObj
        field*: seq[seq[Panel]]
        sizeX: int
        sizeY: int
        fieldSizeX: int
        fieldSizeY: int
        cursor_col: int
        cursor_row: int
        num_bomb: int
        status: GameStatus

proc getCursor*(self: GameBoard): (int, int) =
    return (self.cursor_row, self.cursor_col)

proc setBomb(self: GameBoard, cursor_row, cursor_col:int) =
    randomize()
    while true:
        let x = rand(1..self.sizeX)
        let y = rand(1..self.sizeY)
        if y == cursor_row and x == cursor_col:
            continue
        if not self.field[y][x].isBomb:
            self.field[y][x] = makeBombPanel()
            break

proc calcBombValue(self: GameBoard, y, x: int): int =
    result = 0
    for row in (y - 1) .. (y + 1):
        for col in (x - 1) .. (x + 1):
            # if self.field[row][col] of BombPanel:
            if self.field[row][col].isBomb:
                result += 1

proc calcBombNumber(self: GameBoard) =
    for y in 1 .. self.sizeY:
        for x in 1 .. self.sizeX:
            let current_Panel = self.field[y][x]
            if not current_Panel.isBomb:
                ((BlankPanel)current_Panel).bombValue = self.calcBombValue(y, x)

proc init*(self: GameBoard, x, y, numBomb: int) =
    self.sizeX = x
    self.sizeY = y
    self.num_bomb = numBomb
    self.fieldSizeX = x + 2
    self.fieldSizeY = y + 2
    self.field = newSeq[seq[Panel]](self.fieldSizeY)
    for i in 0 ..< self.fieldSizeY:
        self.field[i] = newSeq[Panel](self.fieldSizeX)
    #FillPanel
    for y in 1 ..< (self.fieldSizeY - 1):
        for x in 1 ..< (self.fieldSizeX - 1):
            self.field[y][x] = makeBlankPanel()
    #FillBoarder
    for y in 0 ..< self.fieldSizeY:
        self.field[y][0] = makeBorder()
        self.field[y][self.fieldSizeX - 1] = makeBorder()
    for x in 0 ..< self.fieldSizeX:
        self.field[0][x] = makeBorder()
        self.field[self.fieldSizeY - 1][x] = makeBorder()
    self.cursor_col = 1
    self.cursor_row = 1
    self.status = Uninitialized

proc setBombAll*(self: GameBoard, cursor_row, cursor_col:int) =
    for _ in 1 .. self.numBomb:
        self.setBomb(cursor_row, cursor_col)
    self.calcBombNumber()
    self.status = Playing

proc setBombAll*(self: GameBoard) =
    for _ in 1 .. self.numBomb:
        self.setBomb(self.cursor_row, self.cursor_col)
    self.calcBombNumber()
    self.status = Playing


proc re_init*(self: GameBoard) =
    self.init(self.sizeX, self.sizeY, self.num_bomb)

proc print(self: GameBoard) =
    var board = ""
    for y in 0 ..< self.fieldSizeY:
        for x in 0 ..< self.fieldSizeX:
            if y == self.cursor_row and x == self.cursor_col:
                board = board & "@ "
            else:
                board = board & self.field[y][x].toString() & " "
        board = board & "\n"
    echo board

proc openAround(self: GameBoard, y, x: int): int =
    result = 0
    for row in (y - 1) .. (y + 1):
        for col in (x - 1) .. (x + 1):
            var p = self.field[row][col]
            if not p.isOpen:
                p.isOpen = true
                result += 1

proc getStatus*(self: GameBoard): GameStatus =
    if self.status == Uninitialized:
        return Uninitialized
    self.status = Win
    for y in 1 .. self.sizeY:
        for x in 1 .. self.sizeX:
            let current_Panel = self.field[y][x]
            if current_Panel.isOpen and current_Panel.isBomb:
                self.status = Lose
                return Lose
            if not current_Panel.isOpen and not current_Panel.isBomb:
                self.status = Playing
    return self.status

proc cascadeOpen(self: GameBoard) =
    var newOpen = 1
    while newOpen > 0:
        newOpen = 0
        for y in 1 .. self.sizeY:
            for x in 1 .. self.sizeX:
                let p = self.field[y][x]
                if p.isOpen and ((BlankPanel)p).bombValue == 0:
                    newOpen += self.openAround(y, x)

proc open*(self: GameBoard, row, col: int): bool =
    var p = self.field[row][col]
    if p.isFlagged:
        result = true
    else:
        p.isOpen = true
        if p.isBomb:
            result = false
        else:
            result = true
    if result:
        self.cascadeOpen()
    discard self.getStatus()

proc open*(self: GameBoard): bool =
    return self.open(self.cursor_row, self.cursor_col)

proc flag*(self: GameBoard, row, col: int) =
    var p = self.field[row][col]
    p.flag

proc bombOpen*(self: GameBoard) =
    for y in 1 .. self.sizeY:
        for x in 1 .. self.sizeX:
            let p = self.field[y][x]
            if not p.isOpen and p.isBomb:
                p.isOpen = true

proc countFlags*(self: GameBoard): int =
    result = 0
    for y in 1 .. self.sizeY:
        for x in 1 .. self.sizeX:
            if self.field[y][x].isFlagged:
                result += 1

proc Up*(self: GameBoard) =
    self.cursor_row -= 1
    if self.cursor_row < 1:
        self.cursor_row = 1

proc Down*(self: GameBoard) =
    self.cursor_row += 1
    if self.cursor_row > self.sizeY:
        self.cursor_row = self.sizeY

proc Left*(self: GameBoard) =
    self.cursor_col -= 1
    if self.cursor_col < 1:
        self.cursor_col = 1

proc Right*(self: GameBoard) =
    self.cursor_col += 1
    if self.cursor_col > self.sizeX:
        self.cursor_col = self.sizeX

proc Flag*(self: GameBoard) =
    self.flag(self.cursor_row, self.cursor_col)