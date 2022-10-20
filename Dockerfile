FROM continuumio/anaconda3:latest

RUN pip install --upgrade pip && \
    pip install autopep8 && \
    pip install Keras && \
    pip install tensorflow

#日本語フォントを拾ってくる
RUN apt  update && \
    apt -y install curl &&\
    apt -y install zip 
RUN curl -L  "https://moji.or.jp/wp-content/ipafont/IPAexfont/ipaexg00401.zip" > font.zip
#展開
RUN unzip font.zip
#展開したファイルをcondaのfontを設定するディレクトリにコピー
RUN cp ipaexg00401/ipaexg.ttf /opt/conda/lib/python3.9/site-packages/matplotlib/mpl-data/fonts/ttf/ipaexg.ttf
#font.familyの書き換え
RUN echo "font.family : IPAexGothic" >>  /opt/conda/lib/python3.9/site-packages/matplotlib/mpl-data/matplotlibrc
#キャッシュを削除
#RUN rm -r /root/.cache/matplotlib


WORKDIR /opt

EXPOSE 9999

ENTRYPOINT ["jupyter-lab", "--ip=0.0.0.0", "--port=9999", "--no-browser" , "--allow-root", "--NotebookApp.token=''"]

CMD ["--notebook-dir=/opt"]

