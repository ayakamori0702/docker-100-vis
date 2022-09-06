### 目的
100本ノックを新しいMACで行うために、docker環境を構築  
`docker-compose up -build`   だけで実行できるようになるか検証  
*** 
ディレクトリに入れるもの  

- GitHubに100本ノック用ファイル
- Dockerfile
- compose.yml
- requirements.txt(ライブラリインストール用)  

全てGitHubにあげる  
***  
jupyterを立ち上げながらbashを扱いたいとき
command+T   ターミナルの切り替え  
`docker ps`   runningのコンテナIDをコピー  
`docker exec -it ID /bin/bash`　　IDをペースト  

`apt update`
`apt install vim`  
`apt install`



