import mine_sweeper
import illwill
import panel
import std/strformat

type Tui = ref object
    tb: TerminalBuffer
    width, height, num_row, num_col: int
    gb: GameBoard

proc newTui*(num_row, num_col, num_bomb: int): Tui =
    var tui = new(Tui)
    tui.width = terminalWidth()
    tui.height = terminalHeight()
    tui.num_row = num_row
    tui.num_col = num_col
    tui.tb = newTerminalBuffer(tui.width, tui.height)
    tui.gb = new GameBoard
    tui.gb.init(num_row, num_col, num_bomb)
    return tui

proc exitProc() {.noconv.} =
    illwillDeinit()
    showCursor()
    quit(0)

proc print_game(self: var Tui) =
    var gb = self.gb
    let status: GameStatus = gb.getStatus
    if status == Lose:
        gb.bombOpen
        # gb.hideCursor
    let num_row = self.num_row
    let num_col = self.num_col
    let (cursor_row, cursor_col) = gb.getCursor
    self.tb = newTerminalBuffer(self.width, self.height)
    self.tb.setForegroundColor(fgYellow)
    self.tb.drawRect(0, 0, (num_col + 1) * 2, num_row + 1)
    for y in 1..num_row:
        for x in 1..num_col:
            let panel = gb.field[y][x]
            var text: string
            if y == cursor_row and x == cursor_col:
                case status:
                of Playing, Uninitialized:
                    self.tb.setForegroundColor(fgMagenta)
                    text = "@"
                of Win:
                    self.tb.setForegroundColor(fgWhite)
                    text = panel.toString
                of Lose:
                    self.tb.setForegroundColor(fgMagenta)
                    text = "B"
            else:
                text = panel.toString
                self.tb.setForegroundColor(fgWhite)
            self.tb.setCursorPos(x * 2, y)
            self.tb.write(text)
    self.tb.setForegroundColor(fgWhite)
    var message = fmt"input <- ^v -> / O open / F flag {gb.countFlags}"
    if status == Win:
        self.tb.setForegroundColor(fgGreen)
        message = "You Win!"
    elif status == Lose:
        self.tb.setForegroundColor(fgMagenta)
        message = "Game Over"

    self.tb.setCursorPos(0, num_row + 2)
    self.tb.write(message)
    self.tb.display()

proc game_end_dialog(self: var Tui) =
    var message = "C: continue, Q: quit"
    self.tb.setForegroundColor(fgWhite)
    self.tb.setCursorPos(0, self.num_row + 3)
    self.tb.write(message)
    self.tb.display()
    while true:
        var key = getKey()
        case key:
        of Key.C:
            self.gb.re_init()
            break
        of Key.Q, Key.Escape:
            exitProc()
        else:
            discard
    self.gb.re_init()

proc start_cui_game(self: var Tui) =
    # define game field
    let num_col = self.num_row
    let num_row = self.num_col
    var gb = self.gb
    illwillInit(fullscreen = true)
    setControlCHook(exitProc)
    hideCursor()
    while true:
        self.print_game
        let status = gb.getStatus()
        if status == Win or status == Lose:
            self.game_end_dialog()
        var key = getKey()
        case key
        of Key.Escape, Key.Q:
            exitProc()
        of Key.Down:
            gb.Down
        of Key.Up:
            gb.Up
        of Key.Left:
            gb.Left
        of Key.Right:
            gb.Right
        of Key.O:
            if gb.getStatus == Uninitialized:
                gb.setBombAll()
            discard gb.open()
        of Key.F:
            gb.Flag
        else: discard

if isMainModule:
    var tui = newTui(9, 9, 10)
    tui.start_cui_game()
