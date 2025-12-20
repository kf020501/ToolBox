help: ## このヘルプを表示
	@grep -E '^[a-zA-Z0-9_.-]+:.*## ' $(MAKEFILE_LIST) \
	| awk 'BEGIN {FS=":.*## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

setup-venv: ## python3-venv を導入し、venv と依存をセットアップ
	sudo apt install -y python3-venv ## venv に必要なパッケージを導入
	python3 -m venv .venv ## 仮想環境を作成
	.venv/bin/pip3 install -r requirements.txt ## 依存関係を導入

activate-venv: ## venv を有効化したシェルを起動
	bash -c 'source .venv/bin/activate && exec bash'

test: ## pytest を実行
	PYTHONPATH=. pytest -vv -s --tb=short --cov=src ## テストを実行
