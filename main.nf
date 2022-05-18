#!/usr/bin/env nextflow
/*
========================================================================================
                         lifebit-ai/xxxx
========================================================================================
lifebit-ai/xxxx
 #### Homepage / Documentation
https://github.com/xxxx
----------------------------------------------------------------------------------------
*/

// Help message

def helpMessage() {
    log.info """
    Usage:
    The typical command for running the pipeline is as follows:
    nextflow run main.nf --bams sample.bam [Options]
    
    Inputs Options:
    --input         Input file

    Resource Options:
    --max_cpus      Maximum number of CPUs (int)
                    (default: $params.max_cpus)  
    --max_memory    Maximum memory (memory unit)
                    (default: $params.max_memory)
    --max_time      Maximum time (time unit)
                    (default: $params.max_time)
    See here for more info: https://github.com/lifebit-ai/hla/blob/master/docs/usage.md
    """.stripIndent()
}

// Show help message
if (params.help) {
  helpMessage()
  exit 0
}



/*--------------------------------------------------------
  Defining and showing header with all params information 
----------------------------------------------------------*/

// Header log info

def summary = [:]

if (workflow.revision) summary['Pipeline Release'] = workflow.revision

summary['Launch dir']                                   = workflow.launchDir
summary['Working dir']                                  = workflow.workDir
summary['Script dir']                                   = workflow.projectDir
summary['User']                                         = workflow.userName
summary['Input']                                        = params.input
summary['Output dir']                                   = params.outdir
summary['organ']                                        = params.organ
summary['bootstrap']                                    = params.bootstrap

log.info summary.collect { k,v -> "${k.padRight(18)}: $v" }.join("\n")
log.info "-\033[2m--------------------------------------------------\033[0m-"



/*-------------------------------------------------
  Setting up introspection variables and channels  
----------------------------------------------------*/

// Importantly, in order to successfully introspect:
// - This needs to be done first `main.nf`, before any (non-head) nodes are launched. 
// - All variables to be put into channels in order for them to be available later in `main.nf`.

ch_repository         = Channel.of(workflow.manifest.homePage)
ch_commitId           = Channel.of(workflow.commitId ?: "Not available is this execution mode. Please run 'nextflow run ${workflow.manifest.homePage} [...]' instead of 'nextflow run main.nf [...]'")
ch_revision           = Channel.of(workflow.manifest.version)

ch_scriptName         = Channel.of(workflow.scriptName)
ch_scriptFile         = Channel.of(workflow.scriptFile)
ch_projectDir         = Channel.of(workflow.projectDir)
ch_launchDir          = Channel.of(workflow.launchDir)
ch_workDir            = Channel.of(workflow.workDir)
ch_userName           = Channel.of(workflow.userName)
ch_commandLine        = Channel.of(workflow.commandLine)
ch_configFiles        = Channel.of(workflow.configFiles)
ch_profile            = Channel.of(workflow.profile)
ch_container          = Channel.of(workflow.container)
ch_containerEngine    = Channel.of(workflow.containerEngine)



/*----------------------------------------------------------------
  Setting up additional variables used for documentation purposes  
-------------------------------------------------------------------*/

Channel
    .of(params.raci_owner)
    .set { ch_raci_owner } 

Channel
    .of(params.domain_keywords)
    .set { ch_domain_keywords }



/*----------------------
  Setting up input data  
-------------------------*/

// Define channels from repository files

projectDir = workflow.projectDir

ch_run_sh_script = Channel.fromPath("${projectDir}/bin/run.sh")
ch_report_dir = Channel.value(file("${projectDir}/bin/report"))

// Define Channels from input

Channel
    .fromPath(params.input)
    .ifEmpty { exit 1, "Cannot find input file : ${params.input}" }
    .splitCsv(sep: '\t', header: true)
    .map { row -> 
      def sample_name = row.sample_name
      def vcf_file_path = row.vcf_file_path
      [sample_name, file(vcf_file_path)]
    }
    .set { ch_input }

/*-----------
  Processes  
--------------*/

// Do not delete this process
// Create introspection report

process obtain_pipeline_metadata {
  publishDir "${params.tracedir}", mode: "copy"

  input:
  val repository from ch_repository
  val commit from ch_commitId
  val revision from ch_revision
  val script_name from ch_scriptName
  val script_file from ch_scriptFile
  val project_dir from ch_projectDir
  val launch_dir from ch_launchDir
  val work_dir from ch_workDir
  val user_name from ch_userName
  val command_line from ch_commandLine
  val config_files from ch_configFiles
  val profile from ch_profile
  val container from ch_container
  val container_engine from ch_containerEngine
  val raci_owner from ch_raci_owner
  val domain_keywords from ch_domain_keywords

  output:
  file("pipeline_metadata_report.tsv") into ch_pipeline_metadata_report
  
  shell:
  '''
  echo "Repository\t!{repository}"                  > temp_report.tsv
  echo "Commit\t!{commit}"                         >> temp_report.tsv
  echo "Revision\t!{revision}"                     >> temp_report.tsv
  echo "Script name\t!{script_name}"               >> temp_report.tsv
  echo "Script file\t!{script_file}"               >> temp_report.tsv
  echo "Project directory\t!{project_dir}"         >> temp_report.tsv
  echo "Launch directory\t!{launch_dir}"           >> temp_report.tsv
  echo "Work directory\t!{work_dir}"               >> temp_report.tsv
  echo "User name\t!{user_name}"                   >> temp_report.tsv
  echo "Command line\t!{command_line}"             >> temp_report.tsv
  echo "Configuration file(s)\t!{config_files}"    >> temp_report.tsv
  echo "Profile\t!{profile}"                       >> temp_report.tsv
  echo "Container\t!{container}"                   >> temp_report.tsv
  echo "Container engine\t!{container_engine}"     >> temp_report.tsv
  echo "RACI owner\t!{raci_owner}"                 >> temp_report.tsv
  echo "Domain keywords\t!{domain_keywords}"       >> temp_report.tsv

  awk 'BEGIN{print "Metadata_variable\tValue"}{print}' OFS="\t" temp_report.tsv > pipeline_metadata_report.tsv
  '''
}

process detect_vcf_origin_tool {
    tag "$sample_name"
    label 'utility_scripts'
    //publishDir "${params.outdir}", mode: 'copy'

    input:
    set val(sample_name), file(vcf_file) from ch_input
    
    output:
    set val(sample_name), file("${sample_name}_input.txt"), file(vcf_file), file(vcf_generation_tool) into ch_detect_vcf_origin_tool

    script:
    bootstrap_option = params.bootstrap ? "--bootstrap" : ""
    """
    touch ${sample_name}_input.txt
    echo "${sample_name}\t${vcf_file.name}" > ${sample_name}_input.txt

    if grep -q "manta" $vcf_file; then
      echo -n "manta" > vcf_generation_tool
    elif grep -q "strelka somatic snv calls" $vcf_file; then
      echo -n "strelka_snv" > vcf_generation_tool 
    elif grep -q "strelka somatic indel calls" $vcf_file; then
      echo -n "strelka_indel" > vcf_generation_tool
    else
      "The VCF needs to be coming from strelka or manta"
      exit 1
    fi
    """
}

// convert the 3rd index of channel array from file to value string
ch_detect_vcf_origin_tool
  .map{ it[0..2] + [it[3].text] }
  .set{ch_detect_vcf_origin_tool_parsed}

process prepare_vcf {
    tag "$sample_name"
    label 'utility_scripts'
    publishDir "${params.outdir}/${output_path}", mode: 'copy'

    input:
    set val(sample_name), file(input_tsv), file(vcf_file), val(vcf_generation_tool) from ch_detect_vcf_origin_tool_parsed
    
    output:
    set val(sample_name), file("${sample_name}_prepareDataOutput"), val(vcf_generation_tool) into ch_prepared_data

    script:
    preparedata_options = params.preparedata_options ? params.preparedata_options : ""
    if(vcf_generation_tool == "manta"){
      output_path = "sv"
      input_cmd = "--manta $input_tsv --mantapass"
    }
    if (vcf_generation_tool == "strelka_snv"){
      output_path = "snv"
      input_cmd = "--strelkasnv $input_tsv"
    }
    if (vcf_generation_tool == "strelka_indel"){
      exit 1, "strelka indel will be supported soon"
    }
    if (!vcf_generation_tool == "manta" || !vcf_generation_tool == "strelka_snv" || !vcf_generation_tool == "strelka_indel"){
      exit 1, "Currently accepted VCF file from the tool - manta and strelka"
    }
    """
    /utility.scripts/prepareData/prepareData.R \
      $input_cmd \
      --genomev $params.genome_version \
      --outdir ${sample_name}_prepareDataOutput \
      $preparedata_options
    """
}

process signature_fit {
    tag "$sample_name"
    label 'signature_tool_lib'
    publishDir "${params.outdir}", mode: 'copy'

    input:
    set val(sample_name), file(prepared_data), val(vcf_generation_tool) from ch_prepared_data
    
    output:
    file ("sv/${sample_name}_signature_fit_out") optional true
    file ("snv/${sample_name}_signature_fit_out") optional true

    script:
    bootstrap_option = params.bootstrap ? "--bootstrap" : ""
    signaturefit_options = params.signaturefit_options ? params.signaturefit_options : ""
    if(vcf_generation_tool == "manta"){
      output_path = "sv/${sample_name}_signature_fit_out"
      input_param = "--svbedpe"
      fit_methond_cmd = '--fitmethod "Fit"'
    }
    if (vcf_generation_tool == "strelka_snv"){
      output_path = "snv/${sample_name}_signature_fit_out"
      input_param = "--snvvcf"
      fit_methond_cmd = '--fitmethod "FitMS"'
    }
    if (vcf_generation_tool == "strelka_indel"){
      exit 1, "strelka indel will be supported soon"
    }
    if (!vcf_generation_tool == "manta" || !vcf_generation_tool == "strelka_snv" || !vcf_generation_tool == "strelka_indel"){
      exit 1, "Currently accepted VCF file from the tool - manta and strelka"
    }
    """
    # TODO - Improve this with https://csvkit.readthedocs.io/en/latest/
    if [[ "$vcf_generation_tool" == "strelka_indel" ]]; then
      cut -f1,3 $prepared_data/analysisTable_hrDetect.tsv | tail -n +2 > $prepared_data/analysisTable_hrDetect_new.tsv
    else
      cut -f1-2 $prepared_data/analysisTable_hrDetect.tsv | tail -n +2 > $prepared_data/analysisTable_hrDetect_new.tsv
    fi
    /signature.tools.lib.dev/scripts/signatureFit \
      $input_param $prepared_data/analysisTable_hrDetect_new.tsv \
      --genomev $params.genome_version \
      --organ $params.organ \
      $fit_methond_cmd \
      $bootstrap_option \
      --outdir $output_path \
      $signaturefit_options
    """
  }
