### やりたいこと
1. 100本ノックを居室用macで行うために、docker環境を構築。  
2. その際に、matplotlibでの日本語表記の豆腐問題も回避したい。   

以上が居室用PCで、`docker-compose up -build` コマンドだけで実行できるか検証  
*** 
## 1. 100本ノック用のdocker環境を構築
在宅用PC (macOS Monterey バージョン12.5.1 M1 2020)で作成する。   
Dockerfile : 以前作成したanaconda環境を使用

### ディレクトリに入れるもの  

- 100本ノック用ファイル
- Dockerfile(日本語表記対応前) 中身↓
```
FROM continuumio/anaconda3:latest

RUN pip install --upgrade pip && \
    pip install autopep8 && \
    pip install Keras && \
    pip install tensorflow


WORKDIR /opt

EXPOSE 8888

ENTRYPOINT ["jupyter-lab", "--ip=0.0.0.0", "--port=8888", "--no-browser" , "--allow-root", "--NotebookApp.token=''"]

CMD ["--notebook-dir=/opt"]
```
- docker-compose.yml  
```
version: '3'
services: 
    anaconda:
        build: .
        volumes:
            - '.:/opt/100knock-process-visualization'
        ports:
            - '8888:8888'
        tty: true
        platform: linux/amd64
```
全てGitHubにあげる  
***  
## 2.日本語表記ができるように、パッケージインストールする(手作業ver)  
[参考URL](http://oyaryo.blogspot.com/2018/03/matplotlib.html)  

インストールするパッケージ:ipaexfont  

<ターミナルでの作業>  
- jupyterを立ち上げながらbashを扱いたいとき  
1.command+T   ターミナルの切り替え  
2.`docker ps`   runningのコンテナIDをコピー  
3.`docker exec -it ID /bin/bash`　　IDをペースト  

### パッケージインストール手順  
`#apt update`  
1.vimをインストール  
`#apt install vim`  

フォントのインストール  
`#apt install fonts-ipaexfont`  
2.matplotlibrc のファイルの場所を探す  
`#find -name matplotlibrc`  

```
./conda/lib/python3.9/site-packages/matplotlib/mpl-data/matplotlibrc
```  
3.vimで編集する  
`#vim ./conda/lib/python3.9/site-packages/matplotlib/mpl-data/matplotlibrc`  中身↓
```
## settings for axes and ticks.  Special text sizes can be defined
## relative to font.size, using the following values: xx-small, x-small,
## small, medium, large, x-large, xx-large, larger, or smaller

#font.family:  IPAexGothic
#font.style:   normal
#font.variant: normal
#font.weight:  normal
#font.stretch: normal
#font.size:    10.0

#font.serif:      DejaVu Serif, Bitstream Vera Serif, Computer Modern Roman, New Century Schoolbook, Century Schoolbook L, Utopia, ITC Bookman, Bookman, Nimbus Roman No9 L, Times New Roman, Times, Palatino, Charter, serif
#font.sans-serif: DejaVu Sans, Bitstream Vera Sans, Computer Modern Sans Serif, Lucida Grande, Verdana, Geneva, Lucid, Arial, Helvetica, Avant Garde, sans-serif


```
- font.family:  IPAexGothic     #外して変更  
- font.serif:      IPAexGothic, DejaVu Serif, Bitstream Vera Serif, Computer Modern Roman, New Century Schoolbook, Century Schoolbook L, Utopia, ITC Bookman, Bookman, Nimbus Roman No9 L, Times New Roman, Times, Palatino, Charter, serif   #外して追記  

4.キャッシュの削除  
`# ~/.cache/matplotlib`  
***
<スクリプトでの作業>  
```
from matplotlib import rcParams
rcParams['font.family'] = 'IPAexGothic'
```  
以上可視化の前に追記  
***
## 日本語表記ができるように、パッケージインストールする(Dockerfileに書くver)  

[参考URL](https://qiita.com/nassy20/items/f67c3ce196558b14dfca)  
[参考URL](https://yukr.hatenablog.com/entry/2020/09/06/202539)  

まず上記URLを参考に、pathやパッケージのバージョンを微妙に変更して書いた。  

```
FROM continuumio/anaconda3:latest

RUN pip install --upgrade pip && \
    pip install autopep8 && \
    pip install Keras && \
    pip install tensorflow

#日本語フォントを拾ってくる
RUN curl -L  "https://moji.or.jp/wp-content/ipafont/IPAexfont/ipaexg00401.zip" > font.zip
#展開
RUN unzip font.zip
#展開したファイルをcondaのfontを設定するディレクトリにコピー
RUN cp ipaexg00401/ipaexg.ttf /opt/conda/lib/python3.9/site-packages/matplotlib/mpl-data/fonts/ttf/ipaexg.ttf
#font.familyの書き換え
RUN echo "font.family : IPAexGothic" >>  /opt/conda/lib/python3.9/site-packages/matplotlib/mpl-data/matplotlibrc
#キャッシュを削除
RUN rm -r ./.cache


WORKDIR /opt

EXPOSE 8888

ENTRYPOINT ["jupyter-lab", "--ip=0.0.0.0", "--port=8888", "--no-browser" , "--allow-root", "--NotebookApp.token=''"]

CMD ["--notebook-dir=/opt"]

```  
`docker-compose up --build`実行  

<続出したエラー一覧>  

- curlがない  
RUN apt  update && \
    apt -y install curl \ 追記
- unzipがない  
apt -y install curl &&\
apt -y install zip 追記  
- './.cache': No such file or directory   
`print(matplotlib.get_cachedir())`コマンドで取得したパス（/root/.cache/matplotlib）を入力してもできない・・・  
コメントアウトしてbuildしたら立ち上がった。→他にインストール等したことがない場合、そもそもcacheファイルが作られていないのでは・・・？  

## 自宅PC(Windows)で検証  
- 変更箇所  
  ・マウント元のファイルパス
  ・（M1チップではない場合）
　　　docker-compose.yml の　platform行をコメントアウトする必要あり。  

立ち上がり、日本語表記にも対応できていた。
