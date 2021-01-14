// Import generic module functions
include { initOptions; saveFiles; getSoftwareName } from './functions'

params.options = [:]
def options    = initOptions(params.options)

process METHYLDACKEL_MBIAS {
    tag "$meta.id"
    publishDir "${params.outdir}",
        mode: params.publish_dir_mode,
        saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:getSoftwareName(task.process), publish_id:meta.id) }

    conda (params.enable_conda ? "bioconda::methyldackel=0.5.1" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "https://depot.galaxyproject.org/singularity/methyldackel:0.5.1--hee625c5_0"
    } else {
        container "quay.io/biocontainers/methyldackel:0.5.1--hee625c5_0"
    }

    input:
    tuple val(meta), path(fasta), path(fai), path(bam), path(bai)

    output:
    tuple val(meta), path("*.txt") , emit: mbias
    path  "*.version.txt" , emit: version

    script:
    def software = getSoftwareName(task.process)
    def prefix  = options.suffix ? "${meta.id}${options.suffix}" : "${meta.id}"
    def all_contexts = meta.comprehensive ? '--CHG --CHH' : ''
    def ignore_flags = meta.ignore_flags ? "--ignoreFlags" : ''
    """
    MethylDackel mbias \\
        $options.args \\
        $all_contexts \\
        $ignore_flags \\
        $fasta \\
        $bam \\
        $prefix \\
        --txt \\
        > ${prefix}.txt

    echo \$(methyldackel --version 2>&1) | cut -f1 -d" " > ${software}.version.txt
    """
}
