FROM ratschlab/wf-base-miniconda4.10.3:v1.0.0

LABEL org.opencontainers.image.source https://github.com/icgc-argo-workflows/rna-seq-splicing

ENV PATH="/tools:${PATH}"

COPY *.py /tools/

ENTRYPOINT ["/usr/bin/env"]

CMD ["/bin/bash"]
