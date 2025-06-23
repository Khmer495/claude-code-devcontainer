# ドメインホワイトリスト更新ガイド

このdevcontainerはSquidプロキシを使用したドメインベースのファイアウォールを含んでいます。コンテナ内から`update-whitelist`コマンド（またはエイリアス`whitelist`）を使用してホワイトリストを更新できます。

## 使い方

### ドメインを追加
```bash
update-whitelist add .example.com
# または
whitelist add .example.com
```

### ドメインを削除
```bash
update-whitelist remove .example.com
# または
whitelist remove .example.com
```

### ホワイトリストされた全ドメインを表示
```bash
update-whitelist list
# または
whitelist list
```

### ホワイトリストを直接編集
```bash
update-whitelist edit
# または
whitelist edit
```
デフォルトのエディタ（デフォルトはnano）でホワイトリストが開きます。

### Squid設定をリロード
```bash
update-whitelist reload
# または
whitelist reload
```
これはadd/remove/edit操作後に自動的に実行されます。

## 使用例

### 新しいサービスへのアクセスを許可
```bash
# 新しいドメインを追加
whitelist add .newservice.com

# 関連する複数のドメインを追加
whitelist add .api.newservice.com
whitelist add .cdn.newservice.com
```

### アクセスを削除
```bash
whitelist remove .untrusted-site.com
```

### 現在のホワイトリストを確認
```bash
whitelist list | grep google
```

## 注意事項

- ドメインパターンはドット（.）で始めることで全サブドメインにマッチします
- ドメインの追加/削除後、変更は即座に反映されます
- ホワイトリストファイルは`/etc/squid/domain-whitelist.txt`にあります
- Squidプロキシはポート3128で動作し、全アプリケーションに自動的に設定されます

## トラブルシューティング

「アクセス拒否」エラーが発生した場合：
1. ドメインがホワイトリストにあるか確認: `whitelist list | grep domain`
2. ドメインがない場合は追加: `whitelist add .domain.com`
3. 設定を再読み込み: `whitelist reload`

### nodeユーザーで利用可能なデバッグコマンド

```bash
# ホワイトリストの内容を確認
whitelist list

# 特定のドメインがホワイトリストにあるか確認
whitelist list | grep example

# ドメインを追加してテスト
whitelist add .example.com
curl -x http://localhost:3128 http://example.com -I

# プロキシが動作しているか確認
curl -x http://localhost:3128 http://github.com -I  # 既存のホワイトリストドメイン
```

### 管理者権限が必要な操作

以下の操作にはrootユーザーまたはsudo権限が必要です：
- Squidのログファイル確認: `sudo tail -f /var/log/squid/access.log`
- Squidの設定テスト: `sudo squid -k parse`
- Squidの再起動: `sudo squid -k shutdown && sudo /usr/local/bin/start-proxy.sh`