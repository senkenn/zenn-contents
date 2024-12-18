---
title: "そこそこ VS Code 拡張を開発してきたのでニッチな拡張開発 Tips を紹介する"
emoji: "🚀"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["vscode", "vscode拡張機能"]
published: true
---

:::message
この記事は「[Visual Studio Code Advent Calendar 2024](https://qiita.com/advent-calendar/2024/visual_studio_code)」18 日目の記事です。
:::

私は今まで 6 つほど VS Code 拡張機能開発に携わってきました。以下一覧です。

:::details 自作 & コントリビュートした VS Code 拡張一覧

自作

https://marketplace.visualstudio.com/items?itemName=senken.sqlsurge

https://marketplace.visualstudio.com/items?itemName=senken.todo-list-for-teams

https://marketplace.visualstudio.com/items?itemName=senken.vsce-format-test-each

https://marketplace.visualstudio.com/items?itemName=senken.vscode-multi-line-uncomment

コントリビュート

https://github.com/zenn-dev/zenn-vscode-extension/pull/115

https://github.com/d-kimuson/ts-type-expand/pull/379

など

:::

今回はその中で得た、公式ドキュメントには書かれていないようなニッチな Tips をいくつか紹介します。

## デバッグが便利になる `launch.json` の Tips

`yo code` で作る最初の `.vscode/launch.json` は以下のようになっていると思います。

```json:初期設定 の .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run Extension",
      "type": "extensionHost",
      "request": "launch",
      "args": [
        "--extensionDevelopmentPath=${workspaceFolder}"
      ],
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "preLaunchTask": "${defaultBuildTask}"
    }
  ]
}
```

これをこのように変更します。

```diff json:.vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Run Extension",
      "type": "extensionHost",
      "request": "launch",
      "args": [
+       "--profile-temp",
        "--extensionDevelopmentPath=${workspaceFolder}"
      ],
      "outFiles": ["${workspaceFolder}/dist/**/*.js"],
      "preLaunchTask": "${defaultBuildTask}",
+     "skipFiles": ["**/app/out/vs/**"]
    }
  ]
}
```

### `args` に `--profile-temp` を追加

`args` は `code` コマンドの引数ですが、これに `--profile-temp` をつけると一時的なプロファイルの状態で VS Code を起動することができます。他の拡張機能と競合していたりするとバグに気づけなかったりするのでおすすめです。

単に他の拡張を無効にしたいなら `--disable-extensions` でも良いんですが、依存関係にある拡張機能があると困るので `--profile-temp` のほうが無難です。
`--install-extension` で依存にある拡張をインストールするようにするのも良きです。

### `skipFiles` に `**/app/out/vs/**` を追加

初期設定のままだと下の画像のように `console.log` などで Debug Console に出したログが `extensionHostProcess.js:xxx` とかいうわけわからんファイルの参照になります。

![alt text](/images/vsce-tips-2024/image-1.png)

これが、`skipFiles` に `**/app/out/vs/**` [^skipFiles] を追加すると、

[^skipFiles]: Linux だと `/usr/share/code/resources/app/out/vs/workbench/api/node/extensionHostProcess.js`, MacOS だと `/Applications/Visual Studio Code.app/Contents/Resources/app/out/vs/workbench/api/node/extensionHostProcess.js` になるので、共通しているパスを指定しています。

![alt text](/images/vsce-tips-2024/image.png)

と、ジャンプしやすくなります（source map 付きでのビルドを忘れずに）。`skipFiles` はデバッグ時にスキップするファイルを指定するオプションです。

## 結合テストの Tips

拡張機能がある程度の規模になってくると結合テストが欲しくなってくると思います。その場合、以下のようなディレクトリ構成がおすすめです。

```sh
examples/ # 拡張機能の使い方例 & 結合テスト用のワークスペース
src/ # 拡張機能のソースコード
test-integration/ # 結合テスト用のテストコード
...
```

結合テストと単体テストで config や snapshot などがバッティングしたりするので、このように分けるのがおすすめです（場合によっては Monorepo にしてもいいです）。以前 snapshot で結合テストだけにあるせいで、単体テストだけ実行するときに snapshot 差分が出たりしてアーキテクチャ変更に迫られたことがありました。
単体テストは好みで `src` 下に置いたり、新たにディレクトリを作ったりしてもいいです。

[Vitest VS Code 拡張](https://github.com/vitest-dev/vscode) [^vitest]でも `src`, `samples`, `test-e2e` のような ディレクトリ構成にしています。

[^vitest]: ちなみに Vitest は Playwright を使って結合テストを行っているようです。本当はこの Playwright を使った結合テストも紹介しようかと思いましたが、Tips というにはまだ発展途上 & 複雑すぎるので省きました。Microsoft さんライブラリ化してくれないかなあ

`yo code` でプロジェクトを作ると `src` の下に結合テスト用の `test` が作られますが、ちゃちゃっと移動しちゃいましょう。

なお、私は結合テストは Jest を用いてテストしています。`beforeAll` や `afterEach` といったメソッドが使いたい方はおすすめです。詳しくは過去の記事で紹介しているので参考まで。

https://zenn.dev/senken/articles/todo-list-for-teams#vscode%E3%82%92%E5%AE%9F%E9%9A%9B%E3%81%AB%E8%B5%B7%E5%8B%95%E3%81%97%E3%81%A6%E8%A1%8C%E3%81%86%E7%B5%90%E5%90%88%E3%83%86%E3%82%B9%E3%83%88

## まとめ

VS Code 拡張開発は自分の開発環境を充実させられてとても楽しいです。[公式ドキュメント](https://code.visualstudio.com/api/extension-guides/overview) や[公式サンプルリポジトリ](https://github.com/microsoft/vscode-extension-samples)、[VS Code 組み込み拡張](https://github.com/microsoft/vscode/tree/main/extensions)などがとても参考になります。みなさんも良き VS Code 拡張ライフを！
