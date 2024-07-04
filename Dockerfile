# Build md to html by jekyll, remove the first title line to avoid duplicate title.
RUN mkdir _site && chmod 777 _site && \
    bundle exec jekyll build

FROM ubuntu:focal as stable

RUN apt-get update -y && apt-get install -y pandoc

ADD stable /g/stable
ADD srs-server /g/srs-server
WORKDIR /g/stable
RUN pandoc README.md -s -o index.html --metadata title='srs-helm'

# Remove all md because it's not needed.
RUN find . -name "*.md" -type f -delete

FROM nginx:stable as dist

COPY --from=docs    /g/_site      /usr/share/nginx/html
COPY --from=stable  /g/stable     /usr/share/nginx/html/stable
COPY --from=stable  /g/srs-server     /usr/share/nginx/html/srs-server
ADD conf /etc/nginx
