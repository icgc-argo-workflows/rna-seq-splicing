FROM ratschlab/wf-base-miniconda4.10.3:v1.0.0

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/rna-seq-splicing
LABEL org.opencontainers.image.authors Andre Kahles (andre.kahles@inf.ethz.ch)
LABEL org.opencontainers.image.title ICGC ARGO RNA-Seq Splicing analysis (SplAdder)

ENV PATH="/tools:${PATH}"

RUN apt-get update

### install SplAdder
RUN pip install spladder==3.0.2

### set up environment
ENV PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:"
ENV LC_ALL=C

RUN groupadd -g 1000 ubuntu &&\
    useradd -l -u 1000 -g ubuntu ubuntu &&\
    install -d -m 0755 -o ubuntu -g ubuntu /home/ubuntu

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
