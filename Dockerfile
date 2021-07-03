FROM ubuntu:latest
RUN apt update
RUN apt install -y nginx wget openjdk-16-jdk
RUN rm -f /etc/nginx/sites-enabled/default
RUN wget https://gist.githubusercontent.com/KangDroid/7de911ad94241243e3b710b651772583/raw/7cb27fa21a36c39fbbeb6f873f8ebcbba64c0d0e/default -O /etc/nginx/sites-enabled/default
RUN echo "set \$service_url http://127.0.0.1:8080;" | tee /etc/nginx/conf.d/service-url.inc
RUN service nginx restart
RUN mkdir /working
RUN wget https://github.com/Navi-Cloud/Navi-Server/releases/download/20210703035957/serverExecutionFile.jar -O /working/baseServer.jar
RUN wget https://gist.github.com/KangDroid/cdba977265df4ea3ba822e9b9d5aa1f0/raw/17b5a9310e5cb3ca9ce7379f0aba50807658f06d/bootstrap.sh -O /working/bootstrap.sh
RUN wget https://gist.github.com/KangDroid/cdba977265df4ea3ba822e9b9d5aa1f0/raw/17b5a9310e5cb3ca9ce7379f0aba50807658f06d/stop_servers.sh -O /working/stop_servers.sh
RUN wget https://gist.github.com/KangDroid/cdba977265df4ea3ba822e9b9d5aa1f0/raw/17b5a9310e5cb3ca9ce7379f0aba50807658f06d/update.sh -O /working/update.sh
RUN chmod a+x /working/*.sh
RUN /working/stop_servers.sh /working/baseServer.jar
RUN /working/bootstrap.sh 
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
CMD ["/bin/bash"]