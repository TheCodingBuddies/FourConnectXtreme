FROM alpine:latest
VOLUME c4xbot

ARG SBCL_VERSION="2.5.10"
ARG URL="https://phoenixnap.dl.sourceforge.net/project/sbcl/sbcl/2.5.10/sbcl-2.5.10-x86-64-linux-binary.tar.bz2?viasf=1"

RUN apk add --no-cache curl gcc sbcl make libc-dev linux-headers

RUN cd /tmp && curl -O https://phoenixnap.dl.sourceforge.net/project/sbcl/sbcl/2.5.10/sbcl-2.5.10-source.tar.bz2?viasf=1 && tar jxvf sbcl-2.5.10-source.tar.bz2 && cd /tmp/sbcl-2.5.10 && sh ./make.sh  && sh ./install.sh && rm -rf /tmp/sbcl* && \
    apk del sbcl && \
    cd /tmp && curl -O https://beta.quicklisp.org/quicklisp.lisp && echo "(load \"quicklisp.lisp\") (quicklisp-quickstart:install :path \"/opt/quicklisp\") (ql::without-prompting (ql:add-to-init-file))" | sbcl && cp $HOME/.sbclrc /etc/sbclrc && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /app

ADD . /app

RUN sbcl --eval "(load \"/app/common_lisp_sbcl.asd\")" \
         --eval "(ql:quickload :c4x-bot)" \
         --eval "(quit)"

ENTRYPOINT ["/app/run.sh"]
