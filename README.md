# mutation-signature-nf

A pipeline to do mutation signature analysis using [signature.tools.lib](https://github.com/Nik-Zainal-Group/signature.tools.lib). This can take a [list of VCF files as input](#input) and process them individually.

Steps - 
1. Detect the VCF files coming from a perticlar tool ([currently supported ones listed below](#currently-supported-vcf-file-from-tools))
2. Pre-processing and filtration of VCF files based on from which tools they coming from. This also standardise the vcf files going into downstream prcoessing.
3. Runs the signature-fit function based on organ-specific signatures.


## Usage 

A basic command to run this pipeline

```bash
nextflow run main.nf --input testdata/input_mix_vcf_origin.tsv --organ "Colorectal" -with-docker
```

Take a look at [testdata/input_mix_vcf_origin.tsv](testdata/input_mix_vcf_origin.tsv)

stdout after running the above command - 

```bash
N E X T F L O W  ~  version 20.01.0
Launching `main.nf` [exotic_northcutt] - revision: fb872d5257
Launch dir        : /home/ec2-user/mutational-signature-nf
Working dir       : /home/ec2-user/mutational-signature-nf/work
Script dir        : /home/ec2-user/mutational-signature-nf
User              : ec2-user
Input             : testdata/input_mix_vcf_origin.tsv
Output dir        : results
organ             : Colorectal
bootstrap         : true
----------------------------------------------------
executor >  local (7)
[2f/5069b7] process > obtain_pipeline_metadata [100%] 1 of 1 ✔
[82/25f847] process > detect_vcf_origin_tool   [100%] 2 of 2 ✔
[6e/d3018c] process > prepare_vcf              [100%] 2 of 2 ✔
[6f/c71c15] process > signature_fit            [100%] 2 of 2 ✔
Completed at: 05-Apr-2022 12:45:49
Duration    : 1m 6s
CPU hours   : (a few seconds)
Succeeded   : 7
```

## Input

A TSV file with two columns 

```
sample_1    path_to_vcf1
sample_2    path_to_vcf2
```

### Currently supported VCF file from tools

* manta
* strelka