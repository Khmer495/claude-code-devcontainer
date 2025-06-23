# Claude Code DevContainer

Claude Code（Anthropic公式のターミナルベースAIコーディングツール）統合開発環境をすぐに使い始めるためのDevContainerテンプレートです。

## ⚠️ セキュリティに関する重要な免責事項

**このリポジトリは、Claude Code（Anthropic公式CLIツール）の高度な機能を活用した開発環境として設計されています。**

### Claude Code利用に関する注意事項

- **Squidプロキシによるファイアウォールを設けていますが、ドメインホワイトリストの設定・管理は使用者の責任です**
- **Claude Codeによる自動化された操作により生じるいかなる問題についても、作者および貢献者は一切の責任を負いません**
- **Claude Codeの動作により意図しないコードの実行、ファイルの変更、外部通信が発生する可能性があります**

## 特徴

- **Claude Code統合**: Claude Code（Anthropic公式CLIツール）が事前インストール済み
- **ネットワーク制御**: Squidプロキシによるドメインベースのアクセス制御
- **セキュアな開発環境**: 必要なドメインのみにアクセスを制限
- **動的ホワイトリスト管理**: 開発中にリアルタイムでアクセス許可を変更可能

## 必要な環境

- Docker（Docker DesktopまたはDocker Engine）
- DevContainer CLI（`npm install -g @devcontainers/cli`）

以下はオプション：
- Visual Studio Code + Dev Containers拡張機能（GUI環境を使用する場合）

## クイックスタート

### 1. リポジトリの準備

```bash
# このリポジトリをクローン
git clone <repository-url>
cd claude-devcontainer
```

### 2. DevContainerの起動

#### Makefileを使用する場合（推奨）

このプロジェクトには日本語化されたMakefileが含まれています：

```bash
# ヘルプを表示
make help

# devcontainerを起動して接続
make dev

# 既存のコンテナを削除して新規起動
make dev-clean
```

#### VS CodeまたはCursorから起動する場合

1. VS Codeでこのリポジトリを開く
2. コマンドパレット（Cmd/Ctrl + Shift + P）を開く
3. "Dev Containers: Reopen in Container"を選択

### 3. 他のプロジェクトでこのテンプレートを使用する

任意のプロジェクトディレクトリにこの`.devcontainer`をコピーします：

```bash
# 既存のプロジェクトに追加
cp -r ./claude-devcontainer/.devcontainer /path/to/your/project/

# Makefileもコピーする場合
cp ./claude-devcontainer/Makefile /path/to/your/project/
```

## 使い方

### Claude Codeの利用

コンテナ内で`claude`コマンドが利用可能です。Claude Codeはプロジェクト全体を理解し、ターミナルから直接コーディング支援を行います：

```bash
# Claude Codeと対話的にコーディング
claude

# ファイルの編集やバグ修正
claude "この関数のバグを修正してください"

# コードベース全体の理解と分析
claude "このプロジェクトのアーキテクチャを説明してください"

# テストの実行と修正
claude "テストを実行して失敗を修正してください"

# Gitワークフロー支援
claude "変更をコミットしてPRを作成してください"
```

### ネットワークアクセス管理

開発中に外部サービスへのアクセスが必要になった場合、`whitelist`コマンドで動的に管理できます：

```bash
# 新しいドメインへのアクセスを許可
whitelist add .api.example.com

# 不要になったドメインを削除
whitelist remove .test-service.com

# 現在のホワイトリストを確認
whitelist list

# 特定のドメインを検索
whitelist list | grep github
```

### プロキシ設定

コンテナ内では自動的にHTTP/HTTPSプロキシが設定されます：

- `http_proxy`: <http://localhost:3128>
- `https_proxy`: <http://localhost:3128>

ほとんどのツールは自動的にこれらの環境変数を使用します。

## カスタマイズ

### ドメインホワイトリストの編集

`.devcontainer/domain-whitelist.txt`を編集して、デフォルトで許可するドメインをカスタマイズできます：

```bash
# プロジェクト固有のドメインを追加
echo ".mycompany.com" >> .devcontainer/domain-whitelist.txt
echo ".internal-api.com" >> .devcontainer/domain-whitelist.txt
```

### 追加ツールのインストール

`.devcontainer/Dockerfile`を編集して、必要なツールを追加できます：

```dockerfile
# 例: Python開発ツールを追加
RUN apt-get update && apt-get install -y python3 python3-pip

# 例: プロジェクト固有のCLIツール
RUN npm install -g your-cli-tool
```

## トラブルシューティング

### アクセス拒否エラー

外部サービスへのアクセスが拒否される場合：

```bash
# アクセスログを確認
sudo tail -f /var/log/squid/access.log

# ドメインを追加
whitelist add .blocked-domain.com

# 設定を再読み込み
whitelist reload
```

### コンテナが起動しない

```bash
# ログを確認
docker logs $(docker ps -aq | head -1)

# クリーンな状態で再起動
make dev-clean
# または
devcontainer up --remove-existing-container --workspace-folder .
```

## セキュリティ機能

このDevContainerは以下のセキュリティ機能を提供します：

- **ネットワーク分離**: ホワイトリストに登録されたドメインのみアクセス可能
- **最小権限**: コンテナはnodeユーザーで実行（rootではない）
- **監査ログ**: すべてのネットワークアクセスが`/var/log/squid/access.log`に記録

## ライセンス

このDevContainerテンプレートはMITライセンスで提供されます。使用にあたっては、上記セキュリティ免責事項をご確認ください。
