# mine_sweeper_nim

![GUI image](gui_image.png)

## About this code

This code is my Nim programming practice.

## Dependency

- [nigui](https://github.com/simonkrauter/NiGui)

## Compilation

```bash
nimble install nigui
nim c --app:gui -d:release mine_sweeper_gui.nim
```

## Impression about Nim

Python に似た文法のコンパイル言語。

ブロックに括弧を使わないので、行数が少なく見通しが良い。

オブジェクト指向言語としては割かし普通。継承とかは普通に書ける。

動的型判定は言語仕様としては可能

```nim
if panel of BombPanel:
    some_process()
else:
    another_process()
```

だが、作者が「特にメリットも無いのでお勧めしない」と言っておりメソッドで解決した。

```nim
if panel.isBomb():
    some_process()
else:
    another_process()
```

可読性的にもこの方が良さそう。

メソッド呼び出しの括弧は省略できる。

```nim
# どちらでも同じ
panel.isBomb()
panel.isBomb
```

プロパティとメソッドを区別する必要が無いのは便利かも。

デフォルトの戻り値用変数として `result` が用意されており、これを使う場合は return 文を書く必要がない。  
そこまでタイプ数節約する必要があるかどうかは疑問だが、まあ嬉しい人には嬉しいのかも……。

for 文の以上/以下はきれいに書ける

```python
for row in (y - 1) .. (y + 1):
    for col in (x - 1) .. (x + 1):
```

アクセス修飾子、mutable/immutable などタイプ数少なく書けるようになっており、モダンで書きやすい。

パッケージシステムもあり、言語仕様も比較的シンプルでスラスラ書ける。好きな言語なのだが、全然はやる気配がない。  

トランスパイル言語というところが影響しているのか、デバッグがしづらい所が仕事で使うには致命的。開発環境の発展が期待される。  
