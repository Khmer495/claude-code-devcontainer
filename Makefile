.PHONY: dev dev-clean help

# デフォルトターゲット
.DEFAULT_GOAL := help

# ヘルプターゲット
help:
	@echo "利用可能なターゲット:"
	@echo "  make dev       - devcontainerを起動して接続"
	@echo "  make dev-clean - 既存のコンテナを削除して新規起動"
	@echo "  make help      - このヘルプメッセージを表示"

# devcontainerを起動して接続
dev:
	@echo "devcontainerを起動しています..."
	@OUTPUT=$$(devcontainer up --workspace-folder . 2>&1); \
	CONTAINER_ID=$$(echo "$$OUTPUT" | grep -o '"containerId":"[^"]*"' | cut -d'"' -f4); \
	if [ -z "$$CONTAINER_ID" ]; then \
		echo "エラー: コンテナIDが見つかりません"; \
		echo "$$OUTPUT"; \
		exit 1; \
	fi; \
	echo "コンテナが起動しました。ID: $$CONTAINER_ID"; \
	echo "コンテナに接続しています..."; \
	docker exec -it "$$CONTAINER_ID" zsh

# 既存のコンテナを削除して新規起動
dev-clean:
	@echo "既存のコンテナを削除して新規起動しています..."
	@OUTPUT=$$(devcontainer up --remove-existing-container --workspace-folder . 2>&1); \
	CONTAINER_ID=$$(echo "$$OUTPUT" | grep -o '"containerId":"[^"]*"' | cut -d'"' -f4); \
	if [ -z "$$CONTAINER_ID" ]; then \
		echo "エラー: コンテナIDが見つかりません"; \
		echo "$$OUTPUT"; \
		exit 1; \
	fi; \
	echo "コンテナが起動しました。ID: $$CONTAINER_ID"; \
	echo "コンテナに接続しています..."; \
	docker exec -it "$$CONTAINER_ID" zsh