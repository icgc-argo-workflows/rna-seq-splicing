#!/usr/bin/env nextflow

/*
  Copyright (c) 2022, Andre Kahles, ETH Zurich

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  Authors:
    Andre Kahles
*/

/********************************************************************/
/* this block is auto-generated based on info from pkg.json where   */
/* changes can be made if needed, do NOT modify this block manually */
nextflow.enable.dsl = 2
version = '0.1.0'  // package version

container = [
    'ghcr.io': 'ghcr.io/icgc-argo-workflows/rna-seq-splicing.alternative-splicing-spladder'
]
default_container_registry = 'ghcr.io'
/********************************************************************/


// universal params go here
params.container_registry = ""
params.container_version = ""
params.container = ""

params.cpus = 1
params.mem = 1  // GB
params.publish_dir = ""  // set to empty string will disable publishDir


// tool specific parmas go here, add / change as needed
params.alignment = ""
params.alignment_index = ""
params.annotation = ""
params.genome = ""
params.output_pattern_gff = "*.gff3"
params.output_pattern_hdf5 = "*.hdf5"
params.output_pattern_txt = "*.txt.gz"


process alternativeSplicingSpladder {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"
  publishDir "${params.publish_dir}/${task.process.replaceAll(':', '_')}", mode: "copy", enabled: params.publish_dir

  cpus params.cpus
  memory "${params.mem} GB"

  input:  // input, make update as needed
    path alignment
    path alinment_index
    path annotation
    path genome

  output:  // output, make update as needed
    path "output_dir/${params.output_pattern_gff}", emit: gff
    path "output_dir/${params.output_pattern_hdf5}", emit: counts
    path "output_dir/${params.output_pattern_txt}", emit: txt

  script:
    """
    mkdir -p output_dir

    spladder build --outdir output_dir  --bams ${alignment} --annotation ${annotation} --readlen 50 --sparse-bam --parallel ${params.cpus} --reference ${genome} --use-anno-support --filter-consensus lenient > spladder.log 2>&1
    """
}

// this provides an entry point for this main script, so it can be run directly without clone the repo
// using this command: nextflow run <git_acc>/<repo>/<pkg_name>/<main_script>.nf -r <pkg_name>.v<pkg_version> --params-file xxx
workflow {
  alternativeSplicingSpladder(
    file(params.alignment),
    file(params.alignment_index),
    file(params.annotation),
    file(params.genome)
  )
}
