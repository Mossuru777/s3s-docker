# s3s-docker
[s3s](https://github.com/frozenpandaman/s3s)をDocker化しました。 

## イメージの構成
- ベースイメージは[python:3-slim](https://hub.docker.com/_/python)です。  
- s3sを`/app/s3s`ディレクトリにcloneしたあと、pipで依存パッケージをインストールしています。  
- s3sの設定ファイル`config.txt`はシンボリックリンクを利用して、`/app/s3s-config`ディレクトリに作成されるようにしています。
- ENTRYPOINTには、`python /app/s3s/s3s.py`を指定しています。
- CMDには、`-r`(未アップロードの戦績をアップロード) と `-M`(モニタリングモード)を指定しています。
### /appディレクトリの構成
```text
/app
├── s3s (s3sリポジトリをclone)
│   ├── config.txt -> /app/s3s-config/config.txt (シンボリックリンク)
│   ⋮
│   └── (その他s3sリポジトリのファイル)
└── s3s-config
    └── config.txt (s3s初回起動時の設定後にs3sによって作成されます)
```

## 使い方

### 準備
1. Dockerをインストールします
2. このリポジトリをcloneします。
   `git clone https://github.com/Mossuru777/s3s-docker.git`

### イメージのビルド (イメージ名を`s3s-docker`、タグを`latest`と仮定)
1. このリポジトリをカレントディレクトリにして、Dockerイメージをビルドします。    
   `docker build -t s3s-docker:latest .`

### コンテナの作成 および 実行 (コンテナ名を`s3s`と仮定)
1. コンテナを作成してバックグラウンドで実行します。  
   `docker container run -dit --name s3s s3s-docker:latest`
2. s3s初回起動時の設定を行うため、コンテナにattachします。  
   `docker container attach s3s`
3. [s3s初回起動時の設定](#s3s初回起動時の設定)を行います。  
   2.のようにコンテナattach直後の場合、s3sのメッセージがすでに出力されて見えない場合があります。  
   その場合には、<kbd>Enter</kbd>を何度か押すと再表示されます。
4. <kbd>Ctrl-p</kbd>,<kbd>Ctrl-q</kbd>のキーシーケンスでdetachします。

## s3s初回起動時の設定
s3sの初回起動時は、[stat.inkのAPIキー](https://stat.ink/profile)などの設定が必要です。
1. コンテナにattachします。
2. s3sのメッセージに従い、必要な情報の入力や操作を行って下さい。
3. 設定完了後は、Dockerfile内のCMD命令やコンテナ実行時に指定したコマンドを引数として、s3sの動作が始まります。
