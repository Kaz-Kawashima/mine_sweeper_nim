import std/strformat

type
    Pannel* = ref object of RootObj
        isOpen*: bool
        isFlagged*: bool

method isBomb*(self: Pannel): bool {.base.} = false

method toString*(self: Pannel): string {.base.} =
    if self.isopen:
        result = "F"
    else:
        result = "z"

method flag* (self: Pannel) =
    if not self.isOpen:
        if self.isFlagged:
            self.isFlagged = false
        else:
            self.isFlagged = true

type
    BombPannel* = ref object of Pannel

method isBomb*(self: BombPannel): bool = true

method toString*(self: BombPannel): string =
    result = "x"
    if self.isOpen:
        result = "B"
    elif self.isFlagged:
        result = "F"

proc makeBombPannel*(): BombPannel =
    result = new BombPannel
    result.isOpen = false
    result.isFlagged = false

type
    BlankPannel* = ref object of Pannel
        bombValue*: int

proc makeBlankPannel*(): BlankPannel =
    result = new BlankPannel
    result.isOpen = false
    result.isFlagged = false
    result.bombValue = 0

proc setBombValue*(self: BlankPannel, value: int) =
    self.bombValue = value

method toString*(self: BlankPannel): string =
    result = "x"
    if self.isOpen:
        if self.bombValue > 0:
            result = fmt"{self.bombValue}"
        else:
            result = " "
    elif self.isFlagged:
        result = "F"

type
    BorderPannel* = ref object of Pannel

proc
    makeBorder*(): BorderPannel =
        result = new BorderPannel
        result.isOpen = true
        result.isFlagged = false

method toString*(self: BorderPannel): string =
    result = "="
