import std/strformat

type
    Panel* = ref object of RootObj
        isOpen*: bool
        isFlagged*: bool

method isBomb*(self: Panel): bool {.base.} = false

method toString*(self: Panel): string {.base.} =
    if self.isopen:
        result = "F"
    else:
        result = "z"

method flag* (self: Panel) {.base.} =
    if not self.isOpen:
        if self.isFlagged:
            self.isFlagged = false
        else:
            self.isFlagged = true

type
    BombPanel* = ref object of Panel

method isBomb*(self: BombPanel): bool = true

method toString*(self: BombPanel): string =
    result = "x"
    if self.isOpen:
        result = "B"
    elif self.isFlagged:
        result = "F"

proc makeBombPanel*(): BombPanel =
    result = new BombPanel
    result.isOpen = false
    result.isFlagged = false

type
    BlankPanel* = ref object of Panel
        bombValue*: int

proc makeBlankPanel*(): BlankPanel =
    result = new BlankPanel
    result.isOpen = false
    result.isFlagged = false
    result.bombValue = 0

proc setBombValue*(self: BlankPanel, value: int) =
    self.bombValue = value

method toString*(self: BlankPanel): string =
    result = "x"
    if self.isOpen:
        if self.bombValue > 0:
            result = fmt"{self.bombValue}"
        else:
            result = " "
    elif self.isFlagged:
        result = "F"

type
    BorderPanel* = ref object of Panel

proc
    makeBorder*(): BorderPanel =
        result = new BorderPanel
        result.isOpen = true
        result.isFlagged = false

method toString*(self: BorderPanel): string =
    result = "="
