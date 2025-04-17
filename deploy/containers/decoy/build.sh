USERNAME=bioflow
IMAGE=generatedecoyA
VERSION=latest

docker build --build-arg VERSION=${VERSION} -t $USERNAME/$IMAGE:$VERSION . \
    && docker tag $USERNAME/$IMAGE:$VERSION $USERNAME/$IMAGE:latest