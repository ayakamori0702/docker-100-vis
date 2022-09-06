### 目的
100本ノックを新しいMACで行うために、docker環境を構築  
`docker-compose up -build`   だけで実行できるようになるか検証  
*** 
ディレクトリに入れるもの  

- GitHubに100本ノック用ファイル
- Dockerfile
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
- compose.yml
- requirements.txt(ライブラリインストール用)  

全てGitHubにあげる  
***  
## 日本語表記ができるように、パッケージインストールする(手作業ver)  
[参考URL](http://oyaryo.blogspot.com/2018/03/matplotlib.html)  
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
`#vim ./conda/lib/python3.9/site-packages/matplotlib/mpl-data/matplotlibrc`  
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
#font.cursive:    Apple Chancery, Textile, Zapf Chancery, Sand, Script MT, Felipa, Comic Neue, Comic Sans MS, cursive
#font.fantasy:    Chicago, Charcoal, Impact, Western, Humor Sans, xkcd, fantasy
#font.monospace:  DejaVu Sans Mono, Bitstream Vera Sans Mono, Computer Modern Typewriter, Andale Mono, Nimbus Mono L, Courier New, Courier, Fixed, Terminal, monospace

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
可視化の前に追記  
***
## 日本語表記ができるように、パッケージインストールする(Dockerfileに書くver)  

[参考URL](https://qiita.com/nassy20/items/f67c3ce196558b14dfca)  
[参考URL](https://yukr.hatenablog.com/entry/2020/09/06/202539)  

まずURLを参考に、pathやパッケージのバージョンを微妙に変更して書いた。  
< before >  
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
- './.cache': No such file or directory パスが違う  
`print(matplotlib.get_cachedir())`コマンドで取得したパス（/root/.cache/matplotlib）を入力してもできない・・・
→すでに手作業で消去してしまっているからかもしれないので、別環境でdockerを立ち上げてみる  
