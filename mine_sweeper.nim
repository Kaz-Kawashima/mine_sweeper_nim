import Panel
import std/random
import std/strutils
import system

type
    GameBoard* = ref object of RootObj
        field*: seq[seq[Panel]]
        sizeX: int
        sizeY: int
        fieldSizeX: int
        fieldSizeY: int

proc setBomb(self: GameBoard) =
    randomize()
    var finished = false
    while not finished:
        let x = rand(1..self.sizeX)
        let y = rand(1..self.sizeY)
        if not self.field[y][x].isBomb:
            self.field[y][x] = makeBombPanel()
            finished = true

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
    self.fieldSizeX = x + 2
    self.fieldSizeY = y + 2
    self.field = newSeq[seq[Panel]](self.fieldSizeY)
    for i in 0 ..< self.fieldSizeY:
        self.field[i] = newSeq[Panel](self.fieldSizeX)
    #FillPanel
    for y in 1 ..< (self.fieldSizeY - 1):
        for x in 1 ..< (self.fieldSizeX - 1):
            self.field[y][x] = makeBlankPanel()
    for _ in 1 .. numBomb:
        self.setBomb()
    #FillBoarder
    for y in 0 ..< self.fieldSizeY:
        self.field[y][0] = makeBorder()
        self.field[y][self.fieldSizeX - 1] = makeBorder()
    for x in 0 ..< self.fieldSizeX:
        self.field[0][x] = makeBorder()
        self.field[self.fieldSizeY - 1][x] = makeBorder()
    self.calcBombNumber()

proc print(self: GameBoard) =
    var board = ""
    for y in 0 ..< self.fieldSizeY:
        for x in 0 ..< self.fieldSizeX:
            board = board & self.field[y][x].toString() & " "
        board = board & "\n"
    echo board

proc user_input(self: GameBoard): tuple[x, y: int] =
    var inputX, inputY: int
    while true:
        echo "input x"
        try:
            inputX = stdin.readLine.parseInt
        except:
            continue
        if inputX in 1 .. self.sizeX:
            break
    while true:
        echo "input y"
        try:
            inputY = stdin.readLine.parseInt
        except:
            continue
        if inputY in 1 .. self.sizeY:
            break
    result = (inputX, inputY)

proc open*(self: GameBoard, x, y: int): bool =
    var p = self.field[y][x]
    if p.isFlagged:
        result = true
    else:
        p.isOpen = true
        if p.isBomb:
            result = false
        else:
            result = true

proc flag*(self: GameBoard, x, y:int) =
    var p = self.field[y][x]
    p.flag

proc openArrownd(self: GameBoard, y, x: int): int =
    result = 0
    for row in (y - 1) .. (y + 1):
        for col in (x - 1) .. (x + 1):
            var p = self.field[row][col]
            if not p.isOpen:
                p.isOpen = true
                result += 1

proc cascadeOpen*(self: GameBoard) =
    var newOpen = 1
    while newOpen > 0:
        newOpen = 0
        for y in 1 .. self.sizeY:
            for x in 1 .. self.sizeX:
                let p = self.field[y][x]
                if p.isOpen and ((BlankPanel)p).bombValue == 0:
                    newOpen += self.openArrownd(y, x)

proc bombOpen*(self: GameBoard) =
    for y in 1 .. self.sizeY:
        for x in 1 .. self.sizeX:
            let p = self.field[y][x]
            if not p.isOpen and p.isBomb:
                p.isOpen = true

proc isFinished*(self: GameBoard): bool =
    for y in 1 .. self.sizeY:
        for x in 1 .. self.sizeX:
            let current_Panel = self.field[y][x]
            if not current_Panel.isOpen and not current_Panel.isBomb:
                return false
    return true

proc countFlags*(self: GameBoard): int =
    result = 0
    for y in 1 .. self.sizeY:
        for x in 1 .. self.sizeX:
            if self.field[y][x].isFlagged:
                result += 1

proc game(self: GameBoard): bool =
    var finished = false
    while not finished:
        self.print()
        let (x, y) = self.user_input()
        var ret = self.open(x, y)
        if ret:
            self.cascadeOpen()
        else:
            self.bombOpen()
            self.print()
            return false
        finished = self.isFinished()
    self.bombOpen()
    self.print()
    return true

if isMainModule:
    var gb = new GameBoard
    gb.init(9, 9, 10)
    let ret = gb.game()
    if ret:
        echo "Game Finished!"
    else:
        echo "Game Over!"
