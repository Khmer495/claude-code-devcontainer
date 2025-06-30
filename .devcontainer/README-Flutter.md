# Flutter on Mac Docker環境での使用方法

## 問題
- FlutterはARM64 Linux版を公式提供していません
- Apple Silicon Mac（M1/M2/M3）のDockerコンテナはデフォルトでARM64で動作します
- そのため、FlutterがDockerコンテナ内で動作しません

## 解決策

### 方法1: x64エミュレーション（推奨）
`devcontainer-x64.json`を使用してx64コンテナを起動します：

```bash
# VS Codeで開く場合
1. コマンドパレット（Cmd+Shift+P）を開く
2. "Dev Containers: Open Folder in Container..."を選択
3. 設定ファイルを聞かれたら`devcontainer-x64.json`を選択

# またはdocker-composeで直接起動
docker build --platform linux/amd64 -t flutter-dev .devcontainer/
docker run --platform linux/amd64 -it flutter-dev
```

**メリット:**
- Flutterが正常に動作します
- すべての機能が使えます

**デメリット:**
- Rosetta 2エミュレーションのため、パフォーマンスが低下します
- ビルド時間が長くなります

### 方法2: ネイティブARM64（現在のDockerfile）
現在のDockerfileはARM64でx64バイナリをダウンロードして実行を試みます。

**注意:**
- 実行時にエラーが発生する可能性があります
- 完全な動作は保証されません

### 方法3: Flutter Web開発のみ
Flutter Webアプリケーションの開発のみを行う場合、DartのみでOKです：

```bash
# Dart SDKのみインストール（asdf経由）
asdf plugin add dart
asdf install dart latest
asdf set --home dart latest
```

## 推奨事項

1. **Flutter開発が必要な場合**: `devcontainer-x64.json`を使用
2. **Flutter不要な場合**: 通常の`devcontainer.json`を使用
3. **パフォーマンス重視**: Mac上でネイティブにFlutterをインストール

## 今後の展望
Flutterチームは ARM64 Linux対応を検討中です。将来的には公式サポートが追加される可能性があります。