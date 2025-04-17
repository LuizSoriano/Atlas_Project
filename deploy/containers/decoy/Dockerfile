ARG  ubuntu_version=latest
FROM ubuntu:${ubuntu_version}

USER root

RUN apt-get update && apt-get install -y \
	build-essential \
	curl \
	git \
	libbz2-dev \
	libcurl4-openssl-dev \
	libgsl0-dev \
	liblzma-dev \
	libncurses5-dev \
	libperl-dev \
	libssl-dev \
	zlib1g-dev \
    bedtools \
	generator-scripting-language \
	cmake \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
ARG htsversion=1.21
ARG mashmapversion=3.1.3
RUN curl -L https://github.com/samtools/htslib/releases/download/${htsversion}/htslib-${htsversion}.tar.bz2 | tar xj && \
	(cd htslib-${htsversion} && ./configure && make install) && \
	curl -L https://github.com/marbl/MashMap/archive/refs/tags/v${mashmapversion}.tar.gz | tar xz && \
	(cd MashMap-${mashmapversion} && cmake -H. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build && mv build/bin/* /usr/local/bin) && \
	curl https://raw.githubusercontent.com/COMBINE-lab/SalmonTools/refs/heads/master/scripts/generateDecoyTranscriptome.sh > generateDecoyTranscriptome.sh && \
	(chmod 755 generateDecoyTranscriptome.sh && mv generateDecoyTranscriptome.sh /usr/local/bin)

CMD ["/bin/bash"]
