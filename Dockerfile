FROM ponylang/ponyc:release

COPY . /src/main/
WORKDIR /src/main/test
RUN make
CMD ./build/release/example
