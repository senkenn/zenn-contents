---
title: "ORMなんていらない？！生SQLクエリ開発を超絶楽にするVSCode拡張を作った [TS+Rust+WASM]"
emoji: "🎉"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["vscode", "sql", "sqls", "sqlsurge", "rust"]
published: true
---

## TL;DR

これができる機能です。

TypeScript with Prisma ⇩
![alt text](/images/vscode-sqlsurge/image.png)

Rust with SQLx ⇩
![alt text](/images/vscode-sqlsurge/image-1.png)

**SQL ファイルだけでなく、他のファイルの生 SQL クエリ(Raw SQL Query)に対しても SQL の LSP が効きます。**
現在は TypeScript 上 の [Prisma](https://github.com/prisma/prisma) と Rust の [SQLx](https://github.com/launchbadge/sqlx) をデフォルトでサポートしています。Prisma のみ、SQL のシンタックスハイライトが効きます。

なお、タイトル詐欺です。

## sqlsurge の設定

https://marketplace.visualstudio.com/items?itemName=senken.sqlsurge

名前は sqlsurge[^1] です。sqlsurge では SQL の Language Server に Golang 製 の [sqls](https://github.com/sqls-server/sqls) を使っているので、

[^1]: もちろん sqls が由来です。surge は急上昇とか躍進とかの意味があるみたいです。ChatGPT と一緒に考えました。気に入ってます。

- Golang
- sqls

が必須となります。sqls をインストールしている人は限られていると思うのでインストールガイドを用意しました。

![alt text](/images/vscode-sqlsurge/sqlsurge-cut.gif)
TypeScript や Rust ファイルを開くと出てくるポップアップで"Install with command"を選ぶとターミナルでインストールコマンドが走ります[^2]。画面リロードしたら補完が効くようになります。

[^2]: Go モジュールのキャッシュがあるので GIF では sqls のインストールが 3 秒くらいで終わってますが、初回は 30 秒くらいはかかると思います。

また、自動補完したい場合、VSCode では文字列中の自動補完はデフォルトで無効になっているので、以下の設定をする必要があります。

```json
{
  "editor.quickSuggestions": {
    "strings": true
  }
}
```

## sqlsurge の仕組み

### 他言語上での SQL Language Server の有効化

https://zenn.dev/mizchi/articles/markdown-code-features

これがなければおそらく私の拡張機能も作れませんでした。@mizchi さんバンザイ。

この記事では触れていませんがどうやっているかというと、VSCode API の [Virtual Document](https://code.visualstudio.com/api/extension-guides/virtual-documents) を使って、仮想ファイル及びドキュメントを作成します（今回は SQL ファイル）。

そして、以下の部分で仮想化されたドキュメントに対して SQL の LSP を発火します。

https://github.com/senkenn/sqlsurge/blob/ebb67d900e0b5f9cf603dd53a34f8fab4f7ce2be/vsce/src/extension.ts#L105-L113
今開いているファイルと仮想的な SQL ファイルが同じエディターを共有しているので、ポジションを指定してあげれば TypeScript や Rust の上に SQL の補完が効くわけです。

おそらくですが、HTML 上で CSS や JS の補完が効くのも同じ仕組みだと思います。

:::details [2024/4/29 追記] 色々調べていたらそれに該当する公式ドキュメントを見つけました

https://code.visualstudio.com/api/language-extensions/embedded-languages

Request Forwarding というのがそれです。補完やエラーといった Language Service の機能を VSCode API を通じて橋渡しできます。今回の補完で言えば Go で作られた SQL Language Server が `vscode.executeCompletionItemProvider` を通じて提供できているというわけです。

読み間違ってなければ HTML 上での CSS や JS の Language Server が効くのも、 CSS, JS のそれぞれで Language Service を実装し、それを Request Forwarding で HTML に適用しているということですね。

おそらく @mizchi さんもこちらを見て実装されたんだと思います。

:::

この機能は VSCode だけなんですかね。Vim とかでもできるんでしょうかね。

### 生 SQL の検出

生 SQL は TypeScript や Rust の AST を解析し、`prisma.$queryRaw`や`sqlx::query!`を探し、引数の SQL を抽出しています。TypeScript は 公式の Compiler API を使って、Rust では syn を使って AST を解析しています。
https://github.com/Microsoft/TypeScript/wiki/Using-the-Compiler-API
https://github.com/dtolnay/syn

syn で AST を扱ってく中で SQL の開始位置と終了位置を取得する必要があったのですが、syn を入れるだけでは取得できず、proc-macro2 でこのように feature を指定する必要があった点にハマりました。
https://github.com/senkenn/sqlsurge/blob/ebb67d900e0b5f9cf603dd53a34f8fab4f7ce2be/sql-extraction/rs/Cargo.toml#L14

ドキュメントにしっかり `Available on crate feature span-locations only.` って書いてあるのでちゃんと読むべきでしたね、、
https://docs.rs/proc-macro2/latest/proc_macro2/struct.LineColumn.html

なお、AST の確認は [astexplorer.net](https://astexplorer.net/) が便利でした（TS は [TypeScript AST Viewer](https://ts-ast-viewer.com/) のほうが見やすいです）

今後 Prisma や SQLx に限らず他のライブラリや自作関数なども対応できるように、カスタマイズ設定もできるようにするつもりです。

### Rust を WASM に変換して VSCode で動かす

上で説明した SQL を検出する Rust コードをどうやって動かしているかというと、[wasm-pack](https://github.com/rustwasm/wasm-pack) で WASM に変換して JavaScript から呼び出して動かしています。VSCode は Electron でバックエンドで WASI サポートの Node.js が動いているので WASM が動きます。

Rust + WASM はこちらの記事が大変参考になりました。~~というかパクりました~~
https://zenn.dev/canalun/articles/cli_and_vscode_extension_by_rust

この記事の通りに今はバンドラーに Webpack を使っているのですが、esbuild の開発体験が良いので本当は esbuild が使いたいです。でもちょっと試してできなかったので一旦断念しました。また再チャレンジします。
https://esbuild.github.io/plugins/#webassembly-plugin

なお、Go や Python など他の言語もサポートがほしい人がいればぜひ Issue にどうぞ。ついでに PR ください（傲慢）
（SQL の範囲と SQL 文字列さえ返せばいいので、コントリビュートしやすいとは思います）

## GitHub Actions での CI

Rust の単体テストと、 @vscode/test-electron + Jest で VSCode 上での結合テストを GitHub Actions で行っています。Ubuntu と macOS でテストを行っています。
詳しくは過去記事で。
https://zenn.dev/senken/articles/todo-list-for-teams#vscode%E3%82%92%E5%AE%9F%E9%9A%9B%E3%81%AB%E8%B5%B7%E5%8B%95%E3%81%97%E3%81%A6%E8%A1%8C%E3%81%86%E7%B5%90%E5%90%88%E3%83%86%E3%82%B9%E3%83%88

なお、無駄にキャッシュもりもりにして CI 時間を半分くらいにしたりしています（wasm-pack のインストールと Rust のビルドに時間がかかって 10 分以上かかることがあるので、、）
https://github.com/senkenn/sqlsurge/blob/ebb67d900e0b5f9cf603dd53a34f8fab4f7ce2be/.github/workflows/e2e-test.yaml

## TODOs

- [x] Support for Prisma in TypeScript
- [x] Support for SQLx in Rust
- [x] Install guide for sqls
- [x] Format SQL (2024/5/3 Support)
- [x] Support custom functions for raw SQL queries, not just Prisma and SQLx (2024/6/21 Support)
- [ ] Execute SQL query
- [ ] Syntax highlight for SQL
- [ ] Show quick info symbol
- [ ] Show sqls config with tree view

## まとめ

生 SQL クエリで補完が効く拡張機能を作りました。既にあるかなと思って調べてみましたがない感じですかね？もしあれば教えてください。
仕事で生 SQL を強いられている方や ORM に恨みを感じている方などはぜひ使ってみてください。

GitHub の Star や拡張機能のレビューなどがもらえると非常にやる気が上がります :pray:

https://github.com/senkenn/sqlsurge
https://marketplace.visualstudio.com/items?itemName=senken.sqlsurge

また、この拡張機能を通じて @mizchi さんと @canalun さんには大変お世話になったので、この場を借りて感謝申し上げます。

## おまけ

Prisma に同じような機能を欲している Issue があったので拡張機能作ったよとコメントした[^3]ところ、なんと [Prisma の方](https://github.com/aqrln)から Star をいただきました！！大変感謝！恐悦至極！唯我独尊！
https://github.com/prisma/prisma/issues/3550

[^3]: Prisma にコントリビュートすれば良かったのでは？という考えもありますが、sqlsurge は色んな言語・ライブラリ上で動作することを目指しているので、ちょっと方向性がずれているかなと思いました。というかプライベートで SQLx を使っていく予定なので、ついでに Prisma にも対応したという感じです。
