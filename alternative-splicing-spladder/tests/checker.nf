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

/*
 This is an auto-generated checker workflow to test the generated main template workflow, it's
 meant to illustrate how testing works. Please update to suit your own needs.
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

// universal params
params.container_registry = ""
params.container_version = ""
params.container = ""

// tool specific parmas go here, add / change as needed
params.alignment = ""
params.alignment_index = ""
params.annotation = ""
params.genome = ""
params.expected_gff = ""
params.expected_hdf5 = ""
params.expected_txt = ""

include { alternativeSplicingSpladder } from '../main'

process gff_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_files
    path expected_files

  output:
    stdout()

  script:
    """
    for event_type in exon_skip alt_3prime alt_5prime intron_retention mult_exon_skip mutex_exons
    do
        out=\$(echo ${output_files} | tr ' ' '\n' | grep \${event_type})
        exp=\$(echo ${expected_files} | tr ' ' '\n' | grep \${event_type})
        diff \${out} \${exp} && (echo "Test PASSED") || ( echo "Test FAILED, gff files mismatch." && exit 1 )
    done && exit 0
    """
}

process gzip_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_files
    path expected_files

  output:
    stdout()

  script:
    """
    for event_type in exon_skip alt_3prime alt_5prime intron_retention mult_exon_skip mutex_exons
    do
        out=\$(echo ${output_files} | tr ' ' '\n' | grep \${event_type})
        exp=\$(echo ${expected_files} | tr ' ' '\n' | grep \${event_type})
        diff <(zcat \${out}) <(zcat \${exp}) && (echo "Test PASSED") || ( echo "Test FAILED, files mismatch." && exit 1 )
    done && exit 0
    """
}

process hdf5_diff {
  container "${params.container ?: container[params.container_registry ?: default_container_registry]}:${params.container_version ?: version}"

  input:
    path output_files
    path expected_files

  output:
    stdout()

  script:
    """
    for event_type in exon_skip alt_3prime alt_5prime intron_retention mult_exon_skip mutex_exons
    do
        out=\$(echo ${output_files} | tr ' ' '\n' | grep \${event_type})
        exp=\$(echo ${expected_files} | tr ' ' '\n' | grep \${event_type})
        diff <(h5ls -r \${out} | sort) <(h5ls -r \${exp} | sort) && (echo "Test PASSED") || ( echo "Test FAILED, files mismatch." && exit 1 )
    done && exit 0
    """
}


workflow checker {
  take:
    alignment
    alignment_index
    annotation
    genome
    expected_gff
    expected_txt
    expected_hdf5

  main:
    alternativeSplicingSpladder(
      alignment,
      alignment_index,
      annotation,
      genome
    )

    gff_diff(
      alternativeSplicingSpladder.out.gff,
      expected_gff
    )

    hdf5_diff(
      alternativeSplicingSpladder.out.counts,
      expected_hdf5
    )

    gzip_diff(
      alternativeSplicingSpladder.out.txt,
      expected_txt
    )
}


workflow {
  checker(
    file(params.alignment),
    file(params.alignment_index),
    file(params.annotation),
    file(params.genome),
    params.expected_gff.collect({it -> file(it)}),
    params.expected_txt.collect({it -> file(it)}),
    params.expected_hdf5.collect({it -> file(it)})
  )
}
