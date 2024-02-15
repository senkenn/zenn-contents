---
title: "[VSCode拡張機能] チーム開発向けのTODO管理ツールを作った ~ Todo List for Teams ~"
emoji: "🗂"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["vscode", "typescript"]
published: true
---

ソースコードに`TODO:` や `FIXME:` のようなプリフィックスをつけてコメントを書いて、それを [Todo Tree](https://marketplace.visualstudio.com/items?itemName=Gruntfuggly.todo-tree) や [Todo+](https://marketplace.visualstudio.com/items?itemName=fabiospampinato.vscode-todo-plus) といった拡張機能で管理している人はいると思います。そんな人はチーム開発していてTODOリストを見たときに、
> 他の人が書いたTODO邪魔だなあ。非表示にできればなあ。
>
と思ったことはないでしょうか？ないわけ無いですよね？ありますよね？あるんです。

今回はこの問題を解決する拡張機能を作りました。`Todo List for Teams` です。

https://marketplace.visualstudio.com/items?itemName=senken.todo-list-for-teams

## Todo List for Teams

:::message alert
Todo List for Teams は以下が前提条件となっています。

- Gitがインストールされていること
- Gitリポジトリのあるディレクトリでワークスペースを開いていること

:::

機能は単純で、よくあるTODOリストに無視する用の`IGNORE LIST`を設けました。無視したいTODOコメントを右クリックすれば`IGNORE LIST`に加えることができます。

![picture 8](/images/todo-list-for-teams/2024-01-17-00-08-17.png)  

「自分が書いたTODOコメントだけみたい」というのがモチベーションだったので、本当はコミットユーザーごとにフィルタリングする機能などをつけたかったのですが、自分のTODOコメントを他の人が移動した場合、あるいはその逆でもコミットするとユーザーが変わってしまってかなり処理が複雑になります。そこでとりあえず「無理リスト」を設けるというシンプルな形にしました。

また、`IGNORE LIST`はワークスペースごとに保存するようにしているので、再度開いたときでも`IGNORE LIST`に入れたTODOコメントを保持してくれます。

## TODOコメントの抽出の仕方

一番苦労した部分について解説します。

基本的に`grep`や`git grep`を使ってTODOコメントを抽出しています。Node.jsの`child_process`モジュールを使ってTypeScript（実行時はJavaScript）からShellコマンドを呼び出しています。
現在は現在のブランチ上にあるTODOコメントを「コミット済みファイルのTODOコメント」+「未追跡ファイルのTODOコメント」に分けて抽出しています。

なお、今はただ`TODO:`とか`FIXME:`とかをgrepしているだけなのでそのコードがコメントであるかは判断していないです（Todo Treeとかはコメントのみ抽出する仕様だったはずです）。

コミット済みファイルの場合

https://github.com/senkenn/todo-list-for-teams/blob/e59ac5f6e3cc5bba133ec202873482ff2f6a5a7e/src/todoListProvider.ts#L109-L118

:::details Copilotによる説明

このコードは、指定されたワークスペースディレクトリに移動し、`git grep`を使用して特定の検索語を含む行を追跡中のファイルから検索します。その後、各一致行に対して`git blame`を実行して、その行を最後に変更したコミットとその作者を特定します。

詳細に分解してみましょう：

1. `bash -c`：bashシェルを起動し、引数として渡されたコマンドを実行します。（筆者の補足：child_processは環境によってShellが異なる可能性があるのでbashで実行させるようにしました）
2. `cd "${this.workspaceRoot}"`：指定されたワークスペースディレクトリに移動します。
3. `git grep -n -E \"${searchWord.source}"`：`git grep`を使用して、正規表現（`-E`オプション）として指定された検索語を含む行を追跡中のファイルから検索します。`-n`オプションは、一致する行の行番号を出力します。
4. `while IFS=: read -r i j _; do ... done`：`git grep`からの出力を読み取り、コロン（`:`）で区切られた各行を解析します。最初のフィールド（ファイルパス）は`i`に、2番目のフィールド（行番号）は`j`に格納されます。
5. `/bin/echo "filePath $i"`：一致したファイルのパスを出力します。
6. `git blame -L "$j","$j" "$i" --porcelain`：一致した行に対して`git blame`を実行します。`-L`オプションは、特定の行範囲（この場合は一致した行だけ）に対して`blame`を実行します。`--porcelain`オプションは、出力を機械可読な形式にします。
7. `/bin/echo ""`：一致の終わりを示すために空行を出力します。
8. 最後に、`execSync`はこのコマンドを同期的に実行し、その出力を文字列として返します。
:::

未追跡ファイルの場合

https://github.com/senkenn/todo-list-for-teams/blob/e59ac5f6e3cc5bba133ec202873482ff2f6a5a7e/src/todoListProvider.ts#L220-L231

:::details Copilotによる説明
このコードは、指定されたワークスペースディレクトリに移動し、`git ls-files --others --exclude-standard`を使用して未追跡のファイルをリストアップします。その後、各ファイルに対して`grep`を実行して、特定の検索語を含む行を検索します。

詳細に分解してみましょう：

1. `cd ${this.workspaceRoot}`：指定されたワークスペースディレクトリに移動します。
2. `IFS='
   '`：IFS（Internal Field Separator）を改行に設定します。これにより、`for`ループは改行で区切られた各行を個別の項目として扱います。
3. `files=$(git ls-files --others --exclude-standard)`：`git ls-files --others --exclude-standard`を使用して未追跡のファイルをリストアップし、その結果を`files`変数に格納します。`--others`オプションは、未追跡のファイルを表示します。`--exclude-standard`オプションは、`.gitignore`、`.git/info/exclude`、`core.excludesFile`で指定されたパターンに一致するファイルを除外します。
4. `for file in $files; do ... done`：`files`変数に格納された各ファイルに対してループを実行します。
5. `grep --with-filename -n -E ${searchWordShell.source} "$file"`：`grep`を使用して、正規表現（`-E`オプション）として指定された検索語を含む行を検索します。`--with-filename`オプションは、一致する行の前にファイル名を表示します。`-n`オプションは、一致する行の行番号を出力します。
6. `|| [ $? -eq 1 ]`：`grep`がエラーコード1（一致する行がない）を返した場合には、エラーを無視します。これにより、一致する行がないファイルがあってもスクリプト全体が失敗することはありません。
7. 最後に、`execSync`はこのコマンドを同期的に実行し、その出力を文字列として返します。
:::

ちなみに`git grep --untracked` で未追跡ファイルを含めて一括で抽出することもできるのですが、未追跡ファイルでは`git blame`が使えないので、Shell上で条件分岐など色々する必要があり、それだったらとTypeScript上で２つに分けることにしました。

他にもNPMモジュールの [simple-git](https://www.npmjs.com/package/simple-git)とか使おうとしたんですが、`git blame`がなかったので諦めました、、、

Shell部分は結構簡単になるかなと思ったらそこそこのロジックになって、今まで知らなかったコマンドやオプションやら調べる羽目になりましたね。バグもここが一番出やすかったです。

ここらへんはもっといい方法がありそうです。VSCodeとかどうやっているんでしょうね。気が向いたらソース読んでみます。

## VSCodeを実際に起動して行う結合テスト

私は今まで2つVSCode拡張機能を作ってきました（[Multi Line Uncomment](https://marketplace.visualstudio.com/items?itemName=senken.vscode-multi-line-uncomment), [Format Test Each](https://marketplace.visualstudio.com/items?itemName=senken.vsce-format-test-each)）が、テストコードは書いてきませんでした。今回はShell部分や初回リリース時にわけのわからないバグが出たりと、これはちゃんとテストしたほうがいいなと感じたので初めてテストコードを書いてみました。

また、実際にコミットしたときときやShellコマンドがVSCode上でしっかり動くかどうかを検証したかったので（単純に興味もあったので）、実際にVSCode上でテストする結合テストを行いました。

今回特筆すべきポイントは以下2点です。

1. Mocha -> Jest への移行
2. TreeViewデータの取得

### Mocha -> Jest への移行

[VSCode公式が提供している拡張機能開発のテンプレート生成](https://code.visualstudio.com/api/get-started/your-first-extension) ではTesting Libraryに[Mocha](https://mochajs.org/)が使われています。しかし今回 `afterEach` のようなメソッドでテスト毎に環境をリセットしたかったのですが、

```txt
ReferenceError: afterEach is not defined
```

というようにエラーが出てしまい、同じようなIssueを探しましたが見つからず、自力解決が難しそうでした。
このエラー関連で探していたところに見つけたのがこのIssueです。

https://github.com/microsoft/vscode-test/issues/37

このIssueはJestへの置き換えをする試みで、ここにあるコメントから下のリポジトリのようにJest用のテンプレートを作ってくださった方がおり、大変参考になりました。Jestでは`afterEach`のメソッドを使うことができたので満足です。

https://github.com/daddykotex/jest-tests

:::message
この設定ではまだ複数のテストファイル（`*.test.js`）には対応しておらず以下のようなエラーが出ます（[ちょうど同リポジトリでIssueを上げてくださっている方がいます](https://github.com/daddykotex/jest-tests/issues/2)）

```txt
    ...

    Cannot find module 'vscode'
    Require stack:
    - /home/senken/personal/todo-list-for-teams/src/test/vscode-environment.ts
    - /home/senken/personal/todo-list-for-teams/node_modules/jest-util/build/requireOrImportModule.js
    - /home/senken/personal/todo-list-for-teams/node_modules/jest-util/build/index.js
    - /home/senken/personal/todo-list-for-teams/node_modules/jest-resolve/build/resolver.js
    - /home/senken/personal/todo-list-for-teams/node_modules/jest-resolve/build/index.js
    - /home/senken/personal/todo-list-for-teams/node_modules/jest-runtime/build/index.js
    - /home/senken/personal/todo-list-for-teams/node_modules/jest-runner/build/testWorker.js
    - /home/senken/personal/todo-list-for-teams/node_modules/jest-runner/node_modules/jest-worker/build/workers/processChild.js

      3 | const vscode = require("vscode");
      4 |
    > 5 | class VsCodeEnvironment extends TestEnvironment {
        |                ^
      6 |       async setup() {
      7 |               await super.setup();
      8 |               this.global.vscode = vscode;
    
    ...
```

:::

<!-- https://github.com/senkenn/todo-list-for-teams/blob/e59ac5f6e3cc5bba133ec202873482ff2f6a5a7e/src/test/suite/extension.test.ts#L11-L25 -->

### TreeViewデータの取得

TODOリストは左サイドバーにTreeViewとして表示していますが、TODOリストデータを取得したあとに本当にTreeViewに表示されているかどうかをテストする必要がありました。

あまり情報がなかったので我流ですが、再帰関数を使ってTreeのデータを取得することができました（昔TypeScript Compiler APIでASTを色々操作していた経験が生きました）。

https://github.com/senkenn/todo-list-for-teams/blob/e59ac5f6e3cc5bba133ec202873482ff2f6a5a7e/src/test/suite/extension.test.ts#L440-L459

`getElements`関数を定義して、455行目で再度`getElements`を呼び出すことで再帰的にTreeアイテムを取得できます。
もしかしたらVSCodeモジュールにいい感じのメソッドがあるかもしれませんが、これでTreeViewを実装した部分のコードを疑いながらテストすることができます。

## GitHub ActionsでのCI

ちなみに、結合テストはGitHub Actionsでも動かしています。

https://github.com/senkenn/todo-list-for-teams/blob/main/.github/workflows/ci.yaml

公式ドキュメントが用意されておりコピペで動かせました。ぜひ導入してみてください。
https://code.visualstudio.com/api/working-with-extensions/continuous-integration#github-actions

## まとめ

チーム開発向けのTODOリストを作ってみました。ぜひ使ってみてください（あと頑張ったのでGitHubのスターください）。要望があればぜひコメントやIssueへどうぞ。

また、今回初めてVSCode拡張機能で真面目にテストしてみました。やはりテストコードがないと手戻りとかデグレとか多くなりがちですね。拡張機能開発する際は実際にVSCodeを起動して行うテストを導入してみてはいかがでしょうか。
