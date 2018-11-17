FROM ponylang/ponyc:release

COPY . /src/main/
WORKDIR /src/main
RUN make
CMD ./build/release/example
