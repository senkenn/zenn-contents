---
title: "複数行のコードのコメント解除が簡単にできるVSCodeの拡張機能を作った"
emoji: "🎉"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["VSCode", "vscode拡張機能", "TypeScript"]
published: true
---

## 何を作ったの？

見るが早しということでGIF。
![Multi Line Uncomment](/images/multi-line-uncomment/20221031_190542_Trim.gif)
このようにESLintのstarred-blockスタイルでコメントアウトしたものを簡単にコメント解除できるものを作りました。

これだけです。ニッチ過ぎますね。

## 成果物

[GitHubリポジトリ](https://github.com/senkenn/vscode-multi-line-uncomment)
[Visual Studio Marketplace](https://marketplace.visualstudio.com/items?itemName=SENKEN.vscode-multi-line-uncomment)

## VSCodeのコメントアウト・コメント解除について

まず、[公式](https://eslint.org/docs/latest/rules/multiline-comment-style)にもある通りESLintの複数行のコメントスタイルには大きく以下の３種類があります。

* `//`: separate-lines

  ```ts
  // console.log("first")
  // console.log("second")
  ```

* `/* */`: bare-block

  ```ts
  /* console.log("first")
     console.log("second") */
  ```

* `/* * */`: starred-block

  ```ts
  /*
   * console.log("first")
   * console.log("second")
   */
  ```

separate-linesスタイルはまあいいとして、bare-blockスタイルはWindowsなら`Alt + Shift + A`でコメントトグルできるのですが、私が探した限りだとどうも**starred-blockスタイルには対応していないっぽい**のです。

なので作りました（本当はVSCode本家にプルリクを出すべきだとは思いますがなんせコードを読んで理解するのが大変）。

## 機能の仕様について

**選択範囲に、starred-blockコメントがあればその部分のみコメント解除をし、なければ標準の`Toggle Line Comment`の挙動になります**
なのでキーボードショートカットも同じ、`CTRL + /`にしています。

速度も体感まったく変わりません。もし使い分けたいようでしたらお手数ですがキーバインドを変えてください。

`v0.0.3`の現在はseparate-linesとstarred-blockの場合しか対応してないです。bare-blockは今後実装するつもりです。
（拡張機能の名前も今後の拡張性を込めた意味合いにしたけどそんなに変わんなさそう）

## その他開発環境とか

* Windows11
* WSL2
* Docker Desktop 4.12.0
* VSCode 1.72.2
* Dev Container 0.251.0（VSCode拡張機能）

[こちらの記事](https://qiita.com/Yukimura127/items/4a16ded90b2ad35ab133)を参考にして、Dockerで拡張機能を作る環境を構築しました。
実際の開発リポジトリは[こちら](https://github.com/senkenn/vsce-base)ですが、筆者好みに色々設定しているのであくまで参考程度に。

WSLからも閲覧・編集したかったので、WSLとVolumeマウントしているのですが権限周りで少し手こずりました。

手順としては

1. 一度、マウントせずにnodeユーザーでコンテナ起動&入る
1. `id`コマンドなどでユーザーIDを確認。
1. WSLで`chown`を使って、そのIDのユーザーに権限を書き換える

という流れで行うのが一番簡単でした。
ベストプラクティスとしては、Dockerfileのエントリポイントで`usermod`などを使ってユーザー情報を書き換える方法かなとは思いますが、めんどくさそうだった（し、今回は個人開発な）のでこれで十分でした。

なお、VSCode拡張機能のDev Containerを使っているのでdocker-compose.ymlファイル類は`.devcontainer`ディレクトリ下に置いています。

### 書いたコード

TypeScriptで書きました。コメントとか抜いたらロジック部は多分100行程度なのでついでに載せておきます（決して、あまり書くことがないから記事をかさ増ししようとしているわけじゃないよ！ほんとのホントだよ！）。
ちなみに筆者は今年からTypeScriptを仕事で書き始めたばかりの新米です。まだまだ甘い部分があるとは思うので、こうしたほうがいいなどありましたらぜひコメントやプルリク等お待ちしています。
この記事を書いた`v0.0.3`時点でのコードです。

:::details src/extension.ts

```ts
import * as vscode from 'vscode';

import { Uncomment } from './uncomment';

/**
 * This method is called when your extension is activated
 * Your extension is activated the very first time the command is executed
 */
export function activate(context: vscode.ExtensionContext): void {

  const disposable = vscode.commands.registerCommand('vscode.multi.line.uncomment.uncomment', async () => {

    const editor = vscode.window.activeTextEditor;
    if(!editor) { // ファイルを何も開いていなかったら何もしない
      return;
    }

    const document = editor.document;
    const selection = editor.selection;

    // 選択開始位置からではなく、行頭から文字列を取得する
    const startPos = new vscode.Position(selection.start.line, 0);
    const selectedLinesRange = new vscode.Range(startPos, selection.end);
    const selectedText = document.getText(selectedLinesRange);

    // コメント行の検索
    const uncomment = new Uncomment(selectedText);
    const [commentStartPosArr, commentEndPosArr] = uncomment.detectMultiLineCommentPos();

    const existsBlockComment = commentStartPosArr.length && commentEndPosArr.length;
    const isMatchNumStartEnd = commentStartPosArr.length === commentEndPosArr.length;
    if(!existsBlockComment || !isMatchNumStartEnd) {
      await vscode.commands.executeCommand('editor.action.commentLine');
      return;
    }

    const ranges = commentStartPosArr.map((unused, i) => 
      new vscode.Range(commentStartPosArr[i], commentEndPosArr[i])
    );
    console.log(ranges); // デバッグ用
      
    await editor.edit(editBuilder => {
      editBuilder.replace(selectedLinesRange, uncomment.uncomment(ranges));
    });

  });

  context.subscriptions.push(disposable);
}

/**
 * This method is called when your extension is deactivated
 */
export function deactivate(): void { }
```

:::

:::details src/uncomment.ts

```ts
import * as vscode from 'vscode';

export class Uncomment {

  private readonly rows: readonly string[];

  /**
   * コンストラクタ
   * @param {string} text 選択範囲の文字列
   */
  public constructor(text: string) {
    this.rows = text.split(/\r\n|\n/); // 改行で行ごとに分割する
  }

  /**
   * 複数行コメントの場所を検出する
   * @return [ コメント開始位置配列, コメント終了位置配列 ]
   */
  public detectMultiLineCommentPos(): readonly vscode.Position[][] {

    const commentStartPosArr: vscode.Position[] = [];
    const commentEndPosArr: vscode.Position[] = [];
    const rows = this.rows;

    for(let i = 0; i < rows.length; i++) {
      for(let j = 0; j < rows[i].length - 1; j++) {

        // コメント先頭行の検出
        if(rows[i][j] === '/' && rows[i][j + 1] === '*') {
          const position = new vscode.Position(i, j);
          commentStartPosArr.push(position);
        }

        // コメント最終行の検出
        if(rows[i][j] === '*' && rows[i][j + 1] === '/') {
          const position = new vscode.Position(i, j - 1);
          commentEndPosArr.push(position);
        }
      }
    }

    return [commentStartPosArr, commentEndPosArr];
  }

  /**
   * アンコメントする（コメント部の削除をする）
   * @param commentRanges コメント行の範囲の配列
   * @return アンコメント後の文字列
   */
  public uncomment(commentRanges: vscode.Range[]): string {

    let commentNo = 0;
    const uncommentRows: string[] = [];
    for(const [rowLine, row] of this.rows.entries()) {
      const commentRange = commentNo < commentRanges.length
        ? commentRanges[commentNo]
        : new vscode.Range(new vscode.Position(0, 0), new vscode.Position(0, 0));

      if(rowLine === commentRange.end.line) {
        commentNo++;
      }

      const isInRange = (commentRange.start.line <= rowLine) && (rowLine < commentRange.end.line);
      console.log(commentNo, commentRange.start, commentRange.end, String(isInRange).padEnd(5, ' '), rowLine.toString().padStart(2, ' '), row); // デバッグ用

      if(rowLine === commentRange.start.line || rowLine === commentRange.end.line) {
        continue;
      }

      if(isInRange) {
        const commentColumnNum = 3;
        const strBeforeComment = row.slice(0, commentRange.start.character);
        const strAfterComment = row.slice(commentRange.start.character + commentColumnNum);

        uncommentRows.push(strBeforeComment + strAfterComment);
      } else {
        uncommentRows.push(row);
      }
    }

    return uncommentRows.join('\n'); // 一つの文字列に結合して返す
  }

}
```

:::
