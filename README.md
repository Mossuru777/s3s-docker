# s3s-docker🦑
[![s3s update check status](https://img.shields.io/github/actions/workflow/status/Mossuru777/s3s-docker/s3s_update-check.yml?label=s3s%20update%20check&logo=GitHub)](https://github.com/Mossuru777/s3s-docker/actions/workflows/s3s_update-check.yml)
[![GitHub Workflow Status (with branch)](https://img.shields.io/github/actions/workflow/status/Mossuru777/s3s-docker/s3s-docker_build-push.yml?branch=main&label=s3s-docker%20build%20check%20%28main%20branch%29&logo=GitHub)](https://github.com/Mossuru777/s3s-docker/actions/workflows/s3s-docker_build-push.yml)  
[![Docker Image Version (latest semver)](https://img.shields.io/docker/v/mossuru777/s3s-docker?color=%23086dd7&logo=Docker&logoColor=%23ffffff)](https://hub.docker.com/r/mossuru777/s3s-docker)
[![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/mossuru777/s3s-docker?color=%23086dd7&logo=Docker&logoColor=%23ffffff)](https://hub.docker.com/r/mossuru777/s3s-docker)

[s3s](https://github.com/frozenpandaman/s3s)をDocker化しました。

また、GitHub Actionsでs3sのバージョンを1日1回[チェック](https://github.com/Mossuru777/s3s-docker/actions/workflows/s3s_update-check.yml)して、  
更新されている時にイメージをビルドして[Docker Hubのリポジトリ(mossuru777/s3s-docker)](https://hub.docker.com/r/mossuru777/s3s-docker)にpushしています。
> GitHub Actionsでビルドする時は、s3sのコミットを特定とビルド高速化のために    
  ビルドを行うよりも前のstepでcheckoutしたs3sのリポジトリ一式をそのままCOPYして利用するよう、  
  [Dockerfile](https://github.com/Mossuru777/s3s-docker/blob/main/Dockerfile)を一部変更してからビルドしています。

## イメージの構成
- ベースイメージは[python:3-slim](https://hub.docker.com/_/python)です。  
- s3sを`/app/s3s`ディレクトリにcloneしたあと、pipで依存パッケージをインストールしています。  
- s3sの設定ファイル`config.txt`はシンボリックリンクを利用して、`/app/s3s-config`内に作成されます。
    > **(注意) このままでは、設定ファイルはコンテナ削除時に一緒に削除されてしまいます。**  
    設定ファイルを保持し続けるためには、<u>s3sの初期設定前(設定ファイル作成前)</u>に  
    `/app/s3s-config`ディレクトリを[バインドマウント](https://docs.docker.jp/storage/bind-mounts.html) もしくは [ボリュームマウント](https://docs.docker.jp/storage/volumes.html)して下さい。
- [Dockerfile](https://github.com/Mossuru777/s3s-docker/blob/main/Dockerfile)のENTRYPOINT命令には、`python /app/s3s/s3s.py`を指定しています。
- s3s.pyに渡す引数は、[Dockerfile](https://github.com/Mossuru777/s3s-docker/blob/main/Dockerfile)のCMD命令で  
  `-r`(未アップロードの戦績をアップロード) と `-M`(モニタリングモード)を指定しています。


### イメージ内 /appディレクトリの構成
```text
/app
├── s3s (s3sリポジトリをclone)
│   ├── config.txt -> /app/s3s-config/config.txt (シンボリックリンク)
│   ⋮
│   └── (その他s3sリポジトリのファイル)
└── s3s-config (設定ファイルディレクトリ)
    └── config.txt (s3sの初期設定後、s3sによって作成されます)
```

## セットアップ

### 1. 事前準備  
Dockerをインストールします。

### 2. イメージを準備  
以下のいずれかの方法でイメージを準備します。

- (推奨) ビルド済みイメージをpull  
   `docker pull mossuru777/s3s-docker:latest`  

- イメージをビルド
  1. このリポジトリをcloneします。  
     `git clone https://github.com/Mossuru777/s3s-docker.git`

  2. cloneしたリポジトリのディレクトリをcontextにして、イメージをビルドします。  
     `docker build -t mossuru777/s3s-docker:latest s3s-docker/`  
     (ビルドするイメージ名:タグ名を`mossuru777/s3s-docker:latest`と仮定しています)

### 3. コンテナを作成
コンテナを作成します。  
ここでは、以下の設定を仮定しています。

- 作成するコンテナ名 : `s3s`
- 設定ファイルディレクトリ : `(ホスト側カレントディレクトリ)/s3s-config`ディレクトリにバインドマウント
- 使用するイメージ名:タグ名 : `mossuru777/s3s-docker:latest`

`docker container create -it --name s3s -v $PWD/s3s-config:/app/s3s-config mossuru777/s3s-docker:latest`  

### 4. s3sの初期設定
s3sの設定ファイル`/app/s3s-config/config.txt`が存在しない初回起動時などでは  
[stat.inkのAPIキー](https://stat.ink/profile)などの初期設定が必要です。

1. [使い方-起動](#起動)を参考に、コンテナをバックグラウンドで起動します。
2. 起動しているコンテナにattachします。  
   `docker container attach s3s`  
   (attachするコンテナ名を`s3s`と仮定しています)
3. s3sのメッセージに従い、必要な情報の入力や操作を行って下さい。  
   ※コンテナにattachする前にs3sからのメッセージがすでに出力されてしまい  
   attach後に見えない場合がありますが、<kbd>Enter</kbd>を何度か入力すると再表示されます。
4. <kbd>Ctrl-p</kbd>,<kbd>Ctrl-q</kbd>のキーシーケンスでdetachします。

## 使い方
ここでは、いずれもコンテナ名を`s3s`と仮定しています。

### 起動
コンテナをバックグラウンドで起動します。    
`docker container start s3s`

### 停止
コンテナを停止します。  
`docker container stop s3s`
