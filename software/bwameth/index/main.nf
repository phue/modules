// Import generic module functions
include { saveFiles; getSoftwareName } from './functions'

params.options = [:]

process BWAMETH_INDEX {
    tag "$fasta"
    label 'process_high'
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:'') }

    conda (params.enable_conda ? "bioconda::bwameth=0.2.2" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/bwameth:0.20--py35_0"
    } else {
        container "quay.io/biocontainers/bwameth:0.20--py35_0"
    }

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*.bwameth.c2t*") , emit: index
    path  "*.version.txt" , emit: version

    script:
    def software = getSoftwareName(task.process)
    """
    bwameth.py index $fasta

    echo \$(bwameth.py --version 2>&1) | cut -f2 -d" " > ${software}.version.txt
    """
}
